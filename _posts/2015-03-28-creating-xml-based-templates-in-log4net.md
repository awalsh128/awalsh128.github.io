---
layout: posts
title: Creating XML based templates in log4net.
date: '2015-03-28T23:51:00.002-07:00'
author: awalsh128
tags: 
modified_time: '2015-03-28T23:51:06.663-07:00'
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-8045654665469421599
blogger_orig_url: https://awalsh128.blogspot.com/2015/03/creating-xml-based-templates-in-log4net.html
---

### Motivation

I decided to use [log4net](https://logging.apache.org/log4net/) for a
recent project I had been working on. There is a concept of
[loggers](https://logging.apache.org/log4net/release/manual/configuration.html#loggers)
and
[appenders](https://logging.apache.org/log4net/release/manual/configuration.html#appenders).
Loggers are composed of appenders and a log threshold. Appenders are
consumers of logging information and provide specific implementations
(eg. file, email, event log, database). You can configure the loggers
and appenders either in the [application
configuration](https://logging.apache.org/log4net/release/manual/configuration.html)
or [at runtime](http://www.roelvanlisdonk.nl/?p=723).

Configuring logging in the application configuration provides the most
flexibility. It is great being able to change settings on the fly,
especially when it is running in a production environment and
redeploying the build is out of the question. Although this approach
comes at the expense of having a lot of information in your application
configuration for the loggers and appenders. No big deal though if you
just have to configure once.

### Why Templates?

I had quite a bit of projects with a lot of redundant logging
configuration information in each one\'s application configuration file.
Much of the information had a standard form that we wanted uniform
across our different projects too (eg. log file name conventions, event
log setup, email format). Also, if we updated the logging appender
configuration for a new standard, we would need to do it to every
project\'s application configuration file. This is where templates came
into play.

### Writing the Code

To cut down the amount of configuration information needed to start a
new project with logging and make the configuration more uniform where
needed, we offloaded it into the code and left the rest in the
application configuration file like so.

``` xml
<log4net xsi:noNamespaceSchemaLocation="log4net.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

<logger name="LoggerTemplate">
  <appender name="SmtpAppenderTemplate" type="log4net.Appender.SmtpAppender">
    <to value="peter@initech.com" />
    <from value="system@initech.com" />
    <smtpHost value="mail.initech.com" />
    <username value="peter" />
    <password value="abc123" />
  </appender>
</logger>

<root>
  <level value="INFO" />
</root>

</log4net>
```

We don\'t use the logger directly but rather as a template for our [root
logger](https://logging.apache.org/log4net/release/manual/configuration.html#root).
Now we just need to craft a method to consume the template and create
the root appenders at runtime.

``` csharp
/// <summary>
/// Get appenders matching the logger template name and use them to populate the root appenders at runtime.
/// </summary>
/// <param name="loggerTemplateName">The logger template name found in the application configuration.</param>
public static void ConfigureRootFromTemplate(string loggerTemplateName)
{
  ILog logTemplate = LogManager.GetLogger(loggerTemplateName);

  if (logTemplate == null)
  {
    throw new ArgumentException(
      String.Format(
        "Logger template {0} not found in log4net configuration. Make sure there is an " +
        "logger in the log4net configuration with the name {0}.",
        loggerTemplateName),
        "loggerTemplateName");
  }

  IAppender[] appenderTemplates = logTemplate.Logger.Repository.GetAppenders();
  var smtpAppenderTemplate = appenderTemplates.FirstOrDefault(a => a is SmtpAppender) as SmtpAppender;

  if (smtpAppenderTemplate == null)
  {
    throw new ArgumentException(
      String.Format(
        "SmtpAppender template not found in log4net configuration. Make sure there is an " +
        "SmtpAppender in the log4net {0} logger.",
        loggerTemplateName),
        "loggerTemplateName");
  }

  // Can repeat the above pattern with other appenders as well.
  // Create appenders using the template information from above.
  
  AddAppendersToRootAndConfigure(
    new AppenderCollection 
 {
      // Put your created appenders here.
    });
}

private static void AddAppendersToRootAndConfigure(AppenderCollection appenders)
{
  // Get the log repository.
  var hierarchy = (Hierarchy)log4net.LogManager.GetRepository();
  // Get the root logger.
  Logger rootLogger = hierarchy.Root;
  foreach (var appender in appenders)
  {
    // Add all the appenders and activate.
    rootLogger.AddAppender(appender);
    ((AppenderSkeleton)appender).ActivateOptions();
  }
  // Flag root logger as configured with new appender information.
  rootLogger.Hierarchy.Configured = true;
}
```

Then just call the configuration method at the application\'s startup.

``` csharp
class Program
{
  /// 
  /// The main entry point for the application.
  /// 
  static void Main()
  {
    // Other startup configuration code.

    log4net.Config.XmlConfigurator.Configure(); // Load the application configuration information.
    Log.ConfigureRootFromTemplate("LoggerTemplate");

    // More startup configuration code.
  }
```

### Considerations

I don\'t recommend using this approach in all cases. It definitely cuts
down the amount of application configuration needed but at the cost of
information hiding, since it has been moved to code. Also, it may not be
obvious to an uninitiated developer what your application configuration
is doing, especially since this template approach is not encoded into
the structure of log4net\'s XML. Although, if you have many projects and
need to effect changes to logging across them, this may be a good
solution for you.

### More Reading & Resources

-   [C&C Inc: Logging Best
    Practices](http://c2.com/cgi/wiki?LoggingBestPractices)
-   [beefycode: Log4Net Recommended Practices pt 1: Your
    Code](http://www.beefycode.com/post/Log4Net-Recommended-Practices-pt-1-Your-Code.aspx)
-   [JayWay: A nice, basic log4net
    setup](http://www.jayway.com/2011/06/13/a-nice-basic-log4net-setup/)
-   [Stack Overflow: Why do loggers recommend using a logger per
    class?](http://stackoverflow.com/questions/3143929/why-do-loggers-recommend-using-a-logger-per-class)
-   [Stack Overflow: log4net: Configure to ignore messages from a
    specific
    class](http://stackoverflow.com/questions/5504148/log4net-configure-to-ignore-messages-from-a-specific-class)
-   [Stack Overflow: Best way to dynamically set an appender file
    path](http://stackoverflow.com/questions/571876/best-way-to-dynamically-set-an-appender-file-path)
