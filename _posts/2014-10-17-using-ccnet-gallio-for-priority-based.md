---
title: Using CC.NET & Gallio for priority based smoke testing.
date: '2014-10-17T11:07:00.002-07:00'
author: awalsh128
tags: 
modified_time: '2015-03-19T10:28:59.720-07:00'
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-2156142502623450610
blogger_orig_url: https://awalsh128.blogspot.com/2014/10/using-ccnet-gallio-for-priority-based.html
---

### Pitfalls in Production

Being able to monitor
[production](http://en.wikipedia.org/wiki/Development_environment_(software_development_process))
services for potential errors is critical. Especially if the services
are dependant on external resources which may become unavailable or
exhibit unexpected behavior. Even if you follow good software
development discipline, this is always a source of concern. Think
network outages, unannounced third party API changes, hosted services
becoming unavailable, etc.

For large software projects, creating a [testing
strategy](http://en.wikipedia.org/wiki/Software_testing) that involves
unit and integration is helpful when managing complexity of the commit
to deployment workflow. Functional/smoke tests are also good to ensure
critical functionality works as expected. Although, in an environment
where the running of your software is dependent on external resources,
you need a system of continuous monitoring that run these smoke tests.

### Monitoring Confusion

At [Xignite](https://www.xignite.com/), we use
[Gallio](https://code.google.com/p/mb-unit/) for our testing framework
and [CC.NET](http://www.cruisecontrolnet.org) for our continuous
integration. I used these tools for my production smoke tests but soon
realized that not all tests were equal. Getting paged at 2am for a test
failure that is not mission critical sucks. Even worse, these lower
priority failures can mask very high priority ones since they cause the
entire [test fixture](http://en.wikipedia.org/wiki/Test_fixture) to
fail, and require scrutiny on behalf of the dev-ops person to ensure
that a high priority failure doesn\'t fall through the cracks.

Consider the following test fixture and how it lumps all the different
tests together.

``` csharp
namespace MyServices.Tests.Smoke
{
   using Gallio.Framework;
   using Gallio.Model;
   using MbUnit.Framework;

   [TestFixture]
   public class OneOfMyServicesTests
   {
      [SetUp]
      public void Setup()
      {
         // Setup an individual test to run.
      }

      [FixtureSetUp]
      public void TestFixtureSetUp()
      {
         // Configure fixture for testing.
      }

      [FixtureTearDown]
      public void TestFixtureTearDown()
      {
         if (TestContext.CurrentContext.Outcome == TestOutcome.Failed)
         {
            // Send signal to monitoring system that test fixture has failed.
         }
         else if (TestContext.CurrentContext.Outcome == TestOutcome.Passed)
         {
            // Send signal to monitoring system that test fixture has succeeded.
         }
         else
         {
            // Handle some other outcome.
         }
      }     

      [Test]
      public void MissionCritical()
      {
         // ...
      }

      [Test]
      public void Important()
      {
         // ...
      }

      [Test]
      public void MinorFunctionality()
      {
         // ...
      }     
   }
}
```

Any test failure will make the entire context outcome to fail whether it
was the mission critical test or the test that affects minor
functionality. I tried looking through the Gallio/MbUnit API, event its
[source](https://github.com/Gallio/mbunit-v3), but couldn\'t find a way
to find out which tests failed within a fixture. If anyone knows how to
determine this, please let me know.

### Prioritized Testing

What I do know though is that you can inherit the `TestAttribute` class
and override its `Execute` method. I created a required parameter to
specify the priority of the test and then used a `LoggedTestingContext`
class to store all the results.

``` csharp
namespace MyServices.Tests
{
   using Gallio.Framework.Pattern;
   using MbUnit.Framework;

   public class LoggedTestAttribute
      : TestAttribute
   {
      public const int MinPriority = 1;
      public const int MaxPriority = 3;

      private readonly int priority;
      public int Priority { get { return this.priority; } }

      public LoggedTestAttribute(int priority)
      {
         if (priority < MinPriority || priority > MaxPriority)
         {
            throw new ArgumentException("Priority must be 1, 2, or 3.", "priority");
         }
         this.priority = priority;
      }

      protected override void Execute(PatternTestInstanceState state)
      {
         try
         {
            base.Execute(state);
            LoggedTestingContext.AddTest(this, state.Test, true);
         }
         catch (Exception)
         {            
            LoggedTestingContext.AddTest(this, state.Test, false);
            throw;
         }
      }
   }
}
```

``` csharp
namespace MyServices.Tests
{
   using System;
   using System.Collections.Generic;
   using System.Linq;
   using Gallio.Framework;
   using Gallio.Model.Tree;

   public static class LoggedTestingContext
   {
      private class TestFailure
      {
         public string FullName { get; private set; }

         public LoggedTestAttribute TestAttribute { get; private set; }

         public TestFailure(LoggedTestAttribute testAttribute, Test test)
         {
            this.FullName = test.FullName;
            this.TestAttribute = testAttribute;
         }
      }

      private const int PriorityCount = LoggedTestAttribute.MaxPriority - LoggedTestAttribute.MinPriority + 1;
      
      private static readonly Dictionary nameToFailure = new Dictionary();

      internal static void AddTest(LoggedTestAttribute testAttribute, Test test, bool passed)
      {         
         if (passed)
         {
            return;
         }
         var failure = new TestFailure(testAttribute, test);
         if (!nameToFailure.ContainsKey(failure.FullName))
         {
            nameToFailure.Add(failure.FullName, failure);
         }
      }

      private static bool HasFailed(Test fixtureTest, int priority)
      {
         return fixtureTest.Children
            .Any(c =>
               nameToFailure.ContainsKey(c.FullName) &&
               nameToFailure[c.FullName].TestAttribute.Priority == priority);
      }

      public static void LogSmokeTests(Test fixtureTest, string serviceName)
      {     
         foreach (var priority in Enumerable.Range(LoggedTestAttribute.MinPriority, PriorityCount))
         {
            if (HasFailed(fixtureTest, priority))
            {
               // Send signal to monitoring system that test fixture has failed for priority # tests.
            }
            else
            {
               // Send signal to monitoring system that test fixture has succeeded for priority # tests.
            }
         }
      }
   }
}
```

Finally, putting it together, I replaced the `TestAttribute` with the
new `LoggedTestAttribute` and then process the results in the test
fixture teardown.

``` csharp
namespace MyServices.Tests.Smoke
{
   using Gallio.Framework;
   using Gallio.Model;
   using MbUnit.Framework;

   [TestFixture]
   public class OneOfMyServicesTests
   {
      [SetUp]
      public void Setup()
      {
         // Setup an individual test to run.
      }

      [FixtureSetUp]
      public void TestFixtureSetUp()
      {
         // Configure fixture for testing.
      }

      [FixtureTearDown]
      public void TestFixtureTearDown()
      {
         LoggedTestingContext.LogSmokeTests(TestContext.CurrentContext.Test, "OneOfMyServices");
      }     

      [LoggedTest(1)]
      public void MissionCritical()
      {
         // ...
      }

      [LoggedTest(2)]
      public void Important()
      {
         // ...
      }

      [LoggedTest(3)]
      public void AffectsFunctionalityByDoesntRequireImmediateAttention()
      {
         // ...
      }     
   }
}
```

### More Reading & Resources

-   [mb-unit:
    Downloads](https://code.google.com/p/mb-unit/downloads/list)
-   [CruiseControl.NET](http://www.cruisecontrolnet.org/)
