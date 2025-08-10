---
title: State behavioral pattern to the rescue.
date: '2014-03-17T22:27:00.000-07:00'
author: awalsh128
tags:
- ".NET"
- C#
- design patterns
modified_time: '2014-03-20T10:45:31.364-07:00'
thumbnail: http://2.bp.blogspot.com/-3UkWChCOHY4/UyWBnlNbLGI/AAAAAAAAg5Y/mqhF-oDM7qs/s72-c/requestresponse-states.png
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-8182782051494253614
blogger_orig_url: https://awalsh128.blogspot.com/2014/03/state-behavioral-pattern-to-rescue.html
---

### The Creeping Problem

I recently found myself developing a request-response style system,
where the lifetime of a request could be interrupted at any moment. For
most same process execution, like your average desktop application, this
is a concern, but arises more often when dealing with multiple
coordinated processes. My case ended up being the latter.

One of the ways to ensure redundancy is to isolate the steps of the
request-response workflow into isolated atomic units or states. This
way, if it fails, it can always be re-executed without having to perform
the work that came before it. It is especially helpful when the total
resources required are large and there is a higher probability of
failure. We can just divvy up the work into states that act like
[idempotent
functions](http://stackoverflow.com/questions/1077412/what-is-an-idempotent-operation).
Below is a great simplification of the actual project I worked on but I
wanted to boil it down to its simplest form, eliminating excessive
states that I have collapsed to the CreateResponse state.

::: {.separator style="clear: both; text-align: center;"}
[![](http://2.bp.blogspot.com/-3UkWChCOHY4/UyWBnlNbLGI/AAAAAAAAg5Y/mqhF-oDM7qs/s1600/requestresponse-states.png)](http://2.bp.blogspot.com/-3UkWChCOHY4/UyWBnlNbLGI/AAAAAAAAg5Y/mqhF-oDM7qs/s1600/requestresponse-states.png)
:::

In my original implementation, I modeled the requests as queued items
(UserRequest) that I would dequeue and start work on.

``` csharp
foreach (var request in requests) // as IEnumerable
{
   switch (request.State)
   {
      case State.ReceiveRequest:
         if (TryReceiveRequest(request)) request.State = State.CreateResponse;
         break;
         
      case State.CreateResponse:
         if (TryCreateResponse(request)) request.State = State.SendResponse;
         break;

      case State.SendResponse:
         if (TrySendResponse(request)) request.State = State.ResponseSent;
         break;

      case State.ResponseSent:
         break;

      case State.Faulted:

      default:
         throw new ArgumentOutOfRangeException("request.State");
   }
   if (request.State != State.ResponseSent && request.State != State.Faulted)
      requests.Enqueue(request);
}
```

Seems simple enough, but in my case the CreateResponse state ended being
fairly computationally intensive and could take anywhere from a few
seconds to several minutes. These long delays could be due to the
workload of remote processes it was waiting on, temporal failure points
like the network or even the system the process was running on. Another
added complexity was that these requests were being serviced in
parallel, by multiple processes that could be on the same system or not.
Lastly, actual production level code never ends up being this simple;
you quickly find yourself adding a lot of instrumentation and covering
of edge cases.

``` csharp
foreach (var request in requests)
{
   log.LogDebug("request.Id = {0}: Request dequeued in state {1}.", request.Id, request.State);
   switch (request.State)
   {
      case State.ReceiveRequest:
         logger.LogDebug("request.Id = {0}: Trying to receive request.", request.Id);
         if (TryReceiveRequest(request)) request.State = State.CreateResponsePart1;
         break;
         
      case State.CreateResponsePart1:
         logger.LogDebug("request.Id = {0}: Trying to create response for part 1.", request.Id);
         if (TryCreateResponsePart1(request)) request.State = State.CreateResponsePart2;
         break;

      case State.CreateResponsePart2:
         logger.LogDebug("request.Id = {0}: Trying to create response for part 2.", request.Id);
         if (TryCreateResponsePart2(request))
         {
            request.State = State.CreateResponsePart3;
         }
         else
         {
            request.State = State.CreateResponsePart1;
            ExecuteCreateResponsePart2Cleanup();
            logger.LogError("request.Id = {0}: Unexpected failure while evaluation create response part 2.", request.Id);
         }
         break;

      case State.CreateResponsePart3:
         logger.LogDebug("request.Id = {0}: Trying to create response for part 3.", request.Id);
         bool unrecoverable;
         if (TryCreateResponsePart3(request, out unrecoverable))
         {
            request.State = State.SendResponse;
         }
         else
         {
           if (unrecoverable)
           {
               logger.LogError("request.Id = {0}: Failure is unrecoverable, faulting request.", request.Id);
               request.State = State.Faulted;
           }
           else
           {
               request.State = State.CreateResponse2;
           }
         }
         break;

      case State.SendResponse:
         logger.LogDebug("request.Id = {0}: Trying to send response.", request.Id);
         if (TrySendResponse(request)) request.State = State.ResponseSent;
         break;

      case State.ResponseSent:
         break;

      case State.Faulted:
         logger.LogCritical("request.Id = {0}: Request faulted.", request.Id);
         break;

      default:
         throw new ArgumentOutOfRangeException("request.State");
   }
   log.LogDebug("request.Id = {0}: Request transitioned to state {1}.", request.Id, request.State);
   if (request.State != State.ResponseSent && request.State != State.Faulted)
   {
      logger.LogDebug("request.Id = {0}: Re-enqueuing request for further evaluation.", request.Id);
      requests.Enqueue(request);
   }
   else
   {
      logger.LogDebug("request.Id = {0}: Request evaluation is complete, not re-enqueuing.", request.Id);
   }
}
```

What a mess! This code quickly starts getting bloated. In addition, not
every state evaluation will be successful and be considered exceptional.
Maybe it is polling another process and can\'t transition until that
process is ready. As the result of each state evaluation changes beyond
a simple yes/no (true/false), we end up with a state machine that could
have multiple transitions. This makes for ugly code and too much
coupling. All the state evaluation logic is in the same class and you
have this huge switch statement. We could get around the extensive
logging by using dependency injection but what do we inject? There is no
consistent call site signature to inject to. The ever growing case
statements could be [extracted into their own
method](http://refactoring.com/catalog/extractMethod.html), but then
[readability](http://programmers.stackexchange.com/questions/162923/what-defines-code-readability)
suffers. This sucks.

You may be saying, \"Well you obviously could solve it by \...\" and I
would agree with you. This code ugliness could be solved many different
ways, and is intentionally crap for the purpose of this post. The major
problems I faced was:

-   A large state machine object and large code blocks.
-   Lack of symmetry in state handling.
-   Multiple method
    [postconditions](http://en.wikipedia.org/wiki/Postcondition) that
    couldn\'t be expressed by the boolean return result alone.
-   Coupling of state transition logic, business logic and diagnostics.

I knew something was wrong but I wasn\'t quite sure how to solve it
without adding more complexity to the system and allowing readability to
suffer. As someone who has had to spend hours reading other people\'s
unreadable code, I didn\'t want to commit the same sin.

### Looking For A Solution

In university, they teach you how to be a good Computer Scientist; you
learn complexity analysis, synthetic languages and the theoretical
underpinning of computation. Although, none of this really prepares you
to be a software engineer. I could concoct my own system, by why do this
when I can stand on the shoulders of giants.

I always read or heard references to the [Gang of Four
book](http://en.wikipedia.org/wiki/Design_Patterns), even listened to
talks by the original authors and became familiar with some of the more
famous patterns
([Factory](http://en.wikipedia.org/wiki/Factory_method_pattern) and
[Singleton](http://en.wikipedia.org/wiki/Singleton_pattern) come to
mind). Maybe there was a solution in there. I can\'t be the first one to
come across this simple design problem. So there I found it in the
[State design pattern](http://en.wikipedia.org/wiki/State_pattern).

::: {.separator style="clear: both; text-align: center;"}
[![](http://upload.wikimedia.org/wikipedia/commons/e/e8/State_Design_Pattern_UML_Class_Diagram.svg)](http://upload.wikimedia.org/wikipedia/commons/e/e8/State_Design_Pattern_UML_Class_Diagram.svg)
:::

The design is pretty simple. You have a context that is used by the end
user, and the states themselves wrapped by the context. The context can
have a range of methods that behave differently based on the concrete
state type being used at that moment (eg. behavior of a cursor click in
a graphics editor). I modified this design, using a single method to
abstract workflow and act as a procedural agent for processing multiple
state machines.

### The Code

The first step was to construct a state object that will be the super
type to all of my concrete states.

``` csharp
public abstract class StateBase   
{
   // Let the concrete type decide what the next transition state will be.
   protected abstract StateBase OnExecute();  

   public StateBase Execute()
   {
      // Can add diagnostic information here.
      return this.OnExecute();   
   }   
}
```

Next I need a context class that can create and run the state machine.

``` csharp
public abstract class StateContextBase
{
   private StateBase state;   

   protected abstract StateBase OnCreate();
   protected abstract StateBase OnExecuted(StateBase nextState);
   protected abstract bool OnIsRunning(StateBase state);

   public StateContextBase(StateBase state)
   {
      this.state = state;
   }

   public StateContextBase Execute()
   {
      // Need to create the state machine from something.
      if (this.state == null)
      {
         // We will get to this later.
         this.state = this.OnCreate();
      }
      // Let the concrete context decide what to do after a state transition.
      this.state = this.OnExecuted(state.Execute());
      return this;
   } 
 
   public bool IsRunning()
   {
      // Have the concrete type tell us when it is in the final state.
      return this.OnIsRunning(this.state);
   }
}
```

While glossing over the details, what will this look like at the
application\'s entry point.

``` csharp
class Program
{
   static void Main(string[] args)
   {
      // Will need to get it from somewhere but won't worry about this for now.
      var requests = Enumerable.Empty<StateContextBase>();

      // Can be changed to false on an exit call.
      var running = true;
      while (running)
      {    
         requests = requests
            .Where(r => r.IsRunning())
            .Select(r => r.Execute());
      }
   }
}
```

That is beautiful! All I see is the state machine decider logic and I
don\'t even need to be concerned with what type of state machines are
running.

So let\'s dive into the details. First, there is the creation of the
state into memory. We have to get this from somewhere, so let\'s add
another abstraction on top of our StateBase super type. Something that
can be persisted in case the process crashes and can be accessed across
many systems (eg. database).

In my case, I used the [Entity
Framework](http://en.wikipedia.org/wiki/Entity_Framework)
[ORM](http://en.wikipedia.org/wiki/Object-relational_mapping), which is
based off of the [unit of
work](http://martinfowler.com/eaaCatalog/unitOfWork.html) and
[repository](http://martinfowler.com/eaaCatalog/repository.html) design
patterns. There is a context (DataContext) that I will get my model
object (UserRequest) from to figure out the current state. A unique key
(UserRequest.Id : Guid) will be used to identify the persisted object.
We won\'t concern ourselves as to why this is just unique and not an
identity key (that could be in another post) but it basically comes down
to the object\'s initial creation at runtime not relying on any
persistence store for uniqueness.

``` csharp
public class DataContext
   : System.Data.Entity.DbContext
{
   public DbSet UserRequests { get; set; }

   public DataContext()
      : base("name=DataContext")
   {
   }
}
```

``` csharp
public abstract class PersistedStateBase<TEntity>
   : StateBase
   where TEntity : class
{
   private Guid id;

   protected abstract StateBase OnExecuteCommit(DataContext context, Guid id, TEntity entity);
   protected abstract TEntity OnExecuteCreate(DataContext context, Guid id);
   protected abstract StateBase OnExecuteRollback(DataContext context, Guid id, TEntity entity);

   public PersistedStateBase(Guid id)
   {
      this.id = id;
   }

   protected override StateBase OnExecute()
   {
      // Also consider exceptions thrown by DataContext.
      StateBase nextState = this;
      using (var context = new DataContext())
      {
         TEntity entity = null;
         try
         {
            entity = this.OnExecuteCreate(context, this.id);
            nextState = this.OnExecuteCommit(context, this.id, entity);
            context.SaveChanges();
         }
         catch (Exception ex)
         {
            // Handle exception.
            nextState = this.OnExecuteRollback(context, this.id, entity);
         }
      }
      return nextState;
   }
}
```

The model object (UserRequest, our entity type) will hold the state as
an enumeration (UserRequest.State) and contain all the data needed for
processing through the state machine.

``` csharp
public enum UserRequestState
{
   None = 0,  
   Receive = 1,  
   CreateResponse = 3,
   SendResponse = 4,
   ResponseSent = 5,
   Faulted = -1,  
}
```

``` csharp
[DataContract]
public class UserRequest
{
   [DataMember]
   public Guid Id { get; private set; }
   [DataMember]
   public UserRequestState State { get; private  set; }

   // Other properties here like the location of the user request and other metadata.

   private UserRequest()  // Required by EF to create the POCO proxy.
   {}

   public UserRequest(Guid id, UserRequestState state)
   {
      this.Id = id;
      this.State = state;
   }
}
```

Now let\'s implement our first state using the types we have created.

``` csharp
public class ReceiveState
   : PersistedStateBase<UserRequest>
{
   public ReceiveState(Guid id)
      : base(id)
   {}
  
   protected override StateBase OnExecuteCommit(DataContext context, Guid id, UserRequest entity)
   {      
      var successful = false;
      var faulted = false;
      // Receive user request and decide whether successful, unsuccessful with retry or
      // unrecoverable/faulted. 
      if (successful)
      {
         return new CreateResponseState(id);
      }
      else
      {
         return faulted ? new FaultedState(id) : this;
      }
   }

   protected override UserRequest OnExecuteCreate(DataContext context, Guid id)
   {
      // Get model object
      return context.UserRequests.Find(id);
   }

   protected override StateBase OnExecuteRollback(DataContext context, Guid id, UserRequest entity)
   {
      // Rollback any changes possibly made in the OnExecuteCommit method and attempt recovery,
      // if possible, in this method. For this example, we will just return the current state.
      return this;
   }
}
```

We need to also make our state context concrete with the type below.
This tends to have more wiring since type per state doesn\'t really
translate well in an ORM. This class could be greater simplified with
attributes on the state types, designating the enumeration value they
map to.

``` csharp
public class UserRequestContext
   : StateContextBase
{
   private static Dictionary<Type, UserRequestState> typeToDbState;
   private static bool databaseRead = false;

   public Guid Id { get; private set; }

   static UserRequestContext()
   {
      databaseRead = false;
      typeToDbState = new Dictionary<Type, UserRequestState>()
      {
         { typeof(ReceiveState), UserRequestState.Receive },
         { typeof(CreateResponseState), UserRequestState.CreateResponse},
         { typeof(SendResponse), UserRequestState.SendResponse},
         { typeof(ResponseSent), UserRequestState.ResponseSent},
         { typeof(FaultedState), UserRequestState.Faulted },
      };
   }

   public UserRequestContext(Guid id)
      : base(null)
   {
      this.Id = id;
   }

   public static IEnumerable<Guid> GetRunningIds()
   {
      if (UserRequestContext.databaseRead)
      {
         var ids = Enumerable.Empty<Guid>(); // Get from message queue.    
         return ids;
      }
      else
      {
         using (var dataContext = new DataContext())
         {
            var ids = dataContext.UserRequests
               .Where(u => 
                  u.State != UserRequestState.ResponseSent &&
                  u.State != UserRequestState.Faulted)
               .Select(u => u.Id)
               .ToArray(); // Force evaluation.

            UserRequestContext.databaseRead = true;

            return ids;
         }
      }
   }

   protected override bool OnIsRunning(StateBase state)
   {
      return !(state is CompleteState);
   }

   protected override StateBase OnCreate()
   {
      using (var dataContext = new DataContext())
      {
         // Maps persisted state enumeration to runtime types.
         var entity = dataContext.UserRequests.Find(this.Id);
         switch (entity.State)
         {
            case UserRequestState.Receive:
               return new ReceiveState(this.Id);

            case UserRequestState.CreateResponse:
               return new CreateResponseState(this.Id);

            case UserRequestState.SendResponse:
               return new SendResponseState(this.Id);

            case UserRequestState.ResponseSent:
               return new ResponseSentState(this.Id);

            case UserRequestState.Faulted:
               return new FaultedState(this.Id);

            default:
               throw new ArgumentOutOfRangeException();
         }
      }
   }

   protected override StateBase OnExecuted(StateBase nextState)
   {
      // Run any other deciding logic in here that is independent 
      // of the states themselves (eg. logging, perf counters).

      return nextState;      
   }
}
```

Finally, let\'s come full circle and show what the application entry
point will look like once all is said and done.

``` csharp
class Program
{
   static void Main(string[] args)
   {
      var requests = Enumerable.Empty<StateContextBase>();

      var running = true;
      while (running)
      {         
         requests = requests
            .Where(r => r.IsRunning())
            // Append new user requests found.
            .Concat((IEnumerable)UserRequestContext
               .GetRunningIds()
               .Select(i => new UserRequestContext(i)));
            .Select(r => r.Execute());
      }
   }
}
```

### Ahhhh Yeah\...

After fleshing it all out, I really got that satisfying feeling you get
as a software engineer when you know that you made the right design
decisions. I isolated my business logic into their own types (eg.
ReceiveRequestState), separated it from the state machine transition
logic, added symmetrical handling of persistence logic by layering it on
top of the state type (PersistedStateBase) and contained the
persistence-runtime bridge (from UserRequest to PersistedStateBase
subtypes) into its own type (UserRequestContext). If I want to add more
states, I can simply add to the model\'s state enumeration
(UserRequest.State) and update the state context (UserRequestContext).
If I want to change the transition logic, all I need to do is go to the
concrete state type itself (eg. ReceiveRequestState) and feel confident
that my variables are all scoped correctly. No coupling, no excessive
mutations and no excessive side effects.

### Using The Right Tool

This design pattern isn\'t for every state machine problem. In simple
cases, it can definitely be overkill; you can see a bit of starter code
is needed. Although, if you find yourself designing a state machine with
multiple outbound transitions and final states, this could be the right
modified pattern for you.

### More Reading & Resources

-   [Amazon: Design Patterns
    Book](http://www.amazon.com/Design-Patterns-Object-Oriented-Addison-Wesley-Professional/dp/0201633612)
-   [Wikipedia: Design Patterns (AKA Gang of Four
    Book)](http://en.wikipedia.org/wiki/Design_Patterns)
-   [Wikipedia: State
    Pattern](http://en.wikipedia.org/wiki/State_pattern)
-   [Software Engineering Radio - Episode 81: Interview with one of the
    Gang of
    Four.](http://www.se-radio.net/2007/12/episode-81-interview-erich-gamma/)
-   [Design Patterns Uncovered: The State
    Pattern](http://java.dzone.com/articles/design-patterns-state)
-   [State Design Pattern: Code examples in other
    languages.](http://sourcemaking.com/design_patterns/state)
-   [State Pattern: Really simple implementation in
    Java.](http://www.tutorialspoint.com/design_pattern/state_pattern.htm)
