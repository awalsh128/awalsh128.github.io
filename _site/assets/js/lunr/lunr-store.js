var store = [{
        "title": "C++ Examples",
        "excerpt":"Asserts (Static) For type support and asserts see the CPP Reference entry which has an exhaustive list. template &lt;typename T&gt; T DoSomething(T value) { static_assert(std::is_same&lt;decltype(value), bool&gt;::value, \"value must be bool\"); // ... } template &lt;typename T&gt; T DoSomething(T value) { static_assert(std::is_floating_point&lt;T&gt;::value, \"value must be an integer type.\"); // ... }...","categories": [],
        "tags": ["C++"],
        "url": "http://localhost:4000/notes/cpp/",
        "teaser": null
      },{
        "title": "Git Notes",
        "excerpt":"Common Commands Short Description Command Description Add git add &lt;pattern&gt;   Add All git add -u Add all pending changes. Clean git clean Clean all untracked changes. Clean Preview git clean -n   Commit Pending git commit -m \"&lt;message&gt;\"   Move git mv &lt;source&gt; &lt;target&gt;   Pull from Master git...","categories": [],
        "tags": ["git"],
        "url": "http://localhost:4000/notes/git/",
        "teaser": null
      },{
        "title": "Using Ubuntu 10.04 with SVN+HTTP.",
        "excerpt":"I setup a server recently using Ubuntu 10.04. LAMP was easy to configure, as was Subversion. Although making Subversion and Apache2 play nice together with DAV SVN was a nightmare. I followed the guide provided but the website location just kept reprompting for my login. After hours of running in circles,...","categories": [],
        "tags": ["SVN","Apache"],
        "url": "http://localhost:4000/using-ubuntu-1004-with-svnhttp/",
        "teaser": null
      },{
        "title": "Representing scientific units in code.",
        "excerpt":"I have been working on implementing a stream reader for IEEE 1451.4 TEDS and came across this interesting paper regarding representation of scientific units in code. It provides solutions to determining unit equivalency (eg. V/(m•kg/s²) = m/(s•A)). Also discovered some indivisible base units that can represent any unit (amp, candela, kelvin,...","categories": [],
        "tags": ["scientific units"],
        "url": "http://localhost:4000/representing-scientific-units-in-code/",
        "teaser": null
      },{
        "title": "Delete long file path names.",
        "excerpt":"I made the stupid mistake of importing an Eclipse project into my workspace when the import location was from the workspace itself. I went to delete the recursive folder when I encountered an error that the file path name was too long to delete. The best manual solution that I found...","categories": [],
        "tags": [],
        "url": "http://localhost:4000/delete-long-file-path-names/",
        "teaser": null
      },{
        "title": "Namespaces for classes.",
        "excerpt":"When designing classes for outside use (eg. API) or as a library component for multiple applications, readability and easy element (field/function) selection is important. No developer likes hunting around for fields or functions; a legible and hierarchical organization of elements aids quicker turnaround time in code delivery. In some cases, a large...","categories": [],
        "tags": ["class namespace"],
        "url": "http://localhost:4000/namespace-within-classes/",
        "teaser": null
      },{
        "title": "Reentrant lock acquires in CLR.",
        "excerpt":"I always like when a post gets to the point (especially after searching in Google). In short, if you perform an operation that waits to acquire a lock, the thread doesn't actually stop. In concrete terms of .NET coding, if you call the WaitOne method on a thread, it may still...","categories": [],
        "tags": ["CLR",".NET","multithreading"],
        "url": "http://localhost:4000/reentrant-lock-acquires-in-clr/",
        "teaser": null
      },{
        "title": "Writing a TEDS (IEEE 1451.4) parser.",
        "excerpt":"I was tasked recently with writing a parser for TEDS bit stream data. There is an IEEE published paper with an overview of the standard but it doesn't give any examples for implementation. I was finally able to find a paper that gave examples but still had trouble parsing the...","categories": [],
        "tags": [".NET","C#","data acquisition"],
        "url": "http://localhost:4000/writing-teds-ieee-14514-parser/",
        "teaser": null
      },{
        "title": "Pseudo random proportional scheduling in games.",
        "excerpt":"I have been working on a game where enemy characters must select a target seemingly at random but such that the distribution of selected targets is balanced. Initially I had come up with a randomization algorithm with weighted values for each target but this became cumbersome and much too complex....","categories": [],
        "tags": ["algorithms"],
        "url": "http://localhost:4000/pseudo-random-proportional-scheduling/",
        "teaser": null
      },{
        "title": "EF 4.1 Code First: Many one-to-one properties for same class type on an object.",
        "excerpt":"I just started using the Entity Framework recently to employ persistence for an already established code base. Initially I was using the \"Model &amp; Database First\" paradigm where a designer is used to layout the data model. Although, this ended up being tedious since my POCO instance had to exactly match...","categories": [],
        "tags": ["Entity Framework"],
        "url": "http://localhost:4000/ef-41-code-first-many-one-to-one/",
        "teaser": null
      },{
        "title": "Entity Framework June 2011 CTP Bug",
        "excerpt":"I recently installed the Entity Framework June 2011 CTP to preview the enum support but ran into a bug along the way that reported an error while processing the template. \\ ::: {.separator style=”clear: both; text-align: center;”} {width=”400” height=”390”} ::: I encountered this error while trying to run an Entity...","categories": [],
        "tags": ["bugs","Entity Framework"],
        "url": "http://localhost:4000/entity-framework-june-2011-ctp-bug/",
        "teaser": null
      },{
        "title": "Detecting cycles in decimal digits and lists.",
        "excerpt":"I was recently working on solving problem 64 for project Euler and one of the needed algorithms was a detection of cycles in a list. This routine works for detecting cycles in lists of cardinality greater than 2. \\ def get_cycle_len(N): i = k = 0 for j in range(2, len(N)):...","categories": [],
        "tags": ["algorithms","Python"],
        "url": "http://localhost:4000/detecting-cycles-in-decimal-digits-and/",
        "teaser": null
      },{
        "title": "POCO not transforming into a POCO proxy.",
        "excerpt":"A POCO (Plain Old CLR Object) must be transformed into a POCO proxy [MyNamespace.MyClass -&gt;{System.Data.Entity.DynamicProxies.MyClass_0A943C2FC37D33304CEB497A9210C754E3F553B50315F8E6F0F7A6FAF43777F2}]{.Apple-style-span style=”font-size: x-small;”}) in order for features like lazy loading and change tracking to work. MSDN has a great article that explains how to prepare a POCO to be transformed into a proxy. If you find...","categories": [],
        "tags": [".NET","Entity Framework","ADO.NET"],
        "url": "http://localhost:4000/poco-not-transforming-into-poco-proxy/",
        "teaser": null
      },{
        "title": "Tips for Java performance on Android.",
        "excerpt":"While Java may be a higher level language that makes code writeability easier, conventions must be broken when developing on Android to reap performance gains. This is especially true for games where logic and rendering must be done on a tight loop. The Android developer page provides helpful tips for...","categories": [],
        "tags": ["Java","performance","Android"],
        "url": "http://localhost:4000/tips-for-java-performance-on-android/",
        "teaser": null
      },{
        "title": "WPF and data multithreading deadlocks.",
        "excerpt":"WPF &amp; Multithreading In designing applications, it may be advantageous to run data processing methods on a separate thread from the UI. This allows greater responsiveness in the application and takes advantage of concurrent computation. The cornerstone interface to any binding in WPF is INotifyPropertyChanged, which is implemented on a...","categories": [],
        "tags": ["multithreading","WPF"],
        "url": "http://localhost:4000/wpf-and-data-multithreading-deadlocks/",
        "teaser": null
      },{
        "title": "Bit specific builds in Visual Studio 2010.",
        "excerpt":"Using Conditioned Tags The Visual Studio 2010 UI does not have options to handle conditional references based on what kind of configuration and platform you are running. For example, you may have a project reference that needs to change depending on whether you are doing a 32 or 64 bit...","categories": [],
        "tags": ["Visual Studio"],
        "url": "http://localhost:4000/bit-specific-builds-in-visual-studio/",
        "teaser": null
      },{
        "title": "Converting thermocouple voltages to temperature.",
        "excerpt":"Background Unlike most sensors used in data acquisition, thermocouples do not have a linear mapping between their voltage and celcius values. This means that instead of factoring some scalar value against the data, in order to scale it to engineering units (eg. volts to acceleration), an experimentally derived equation must...","categories": [],
        "tags": ["data acquisition"],
        "url": "http://localhost:4000/converting-thermocouple-voltages-to/",
        "teaser": null
      },{
        "title": "Automate IIS enable on Windows 7.",
        "excerpt":"Background There are plenty of sites that will tell you how to enable IIS through the Control Panel. Although, if you are tasked with enabling IIS automatically (eg. for an installer), it can be a nightmare. This is only really needed though in special cases where the installer has more...","categories": [],
        "tags": ["batch","IIS"],
        "url": "http://localhost:4000/automate-iis-enable-on-windows-7/",
        "teaser": null
      },{
        "title": "Licensing using XML digital signing.",
        "excerpt":"Motivation One of the main concerns in any licensing implementation is that authored license files are coming from the trusted authority (ie. your company) and not some third party. This can be accomplished in software by encrypting and decrypting the license with a single key, but symmetric key storage can...","categories": [],
        "tags": ["security",".NET","XML"],
        "url": "http://localhost:4000/licensing-using-xml-digital-signing/",
        "teaser": null
      },{
        "title": "Implementing a bit reader/writer in C.",
        "excerpt":"Introduction I was working on implementing a simple compression tool based on naive Huffman coding and initially assumed all of my prefix codes would be at or under a byte long. Although I failed to account for the worst case of Huffman coding, which can yield codes up to 255...","categories": [],
        "tags": ["entropy encoding","C","compression","raw text","bit twiddling"],
        "url": "http://localhost:4000/implementing-bit-readerwriter-in-c/",
        "teaser": null
      },{
        "title": "IMAPI version 2 managed wrapper.",
        "excerpt":"Introduction Microsoft introduced native image mastering support in Vista, going forward. The library itself is not too complex but the latest version of the image mastering API (IMAPI) has some quirks. This is well documented by Eric Haddan in his article describing how to build an interop file and use...","categories": [],
        "tags": [".NET","IMAPI","C#"],
        "url": "http://localhost:4000/imapi-version-2-managed-wrapper/",
        "teaser": null
      },{
        "title": "Understanding compression and Huffman Coding.",
        "excerpt":"Definitions In a lot of texts regarding compression you will run across various conventions of syntax to describe the coding of data. Much of them are used in fields like automata theory, group theory and statistics. Although, the field of coding theory itself has a long and rich history in...","categories": [],
        "tags": ["algorithms","entropy encoding","C","compression"],
        "url": "http://localhost:4000/understanding-compression-and-huffman/",
        "teaser": null
      },{
        "title": "Reading and writing large binary data in T-SQL and ADO.NET.",
        "excerpt":"Introduction In some cases, you may want to read/write binary data from/to your relational database. This can be a problem when the data set size exceeds the memory address size (eg. 32-bit processes) or the managed large object heap cannot load it all without throwing an OutOfMemoryException. In those cases,...","categories": [],
        "tags": [".NET","C#","raw text","T-SQL","ADO.NET"],
        "url": "http://localhost:4000/reading-and-writing-large-binary-data/",
        "teaser": null
      },{
        "title": "Text generation using Markov chains.",
        "excerpt":"Introduction If you are already familiar with finite automata, then understanding a Markov chain will not be as hard. If you are not familiar with one, you can think of finite automata as a flowchart, with states and paths leading from one state to another based on some decision being...","categories": [],
        "tags": ["Markov chains","Python","natural language processing"],
        "url": "http://localhost:4000/text-generation-using-markov-chains/",
        "teaser": null
      },{
        "title": "Automated combinatorial and spot testing of web service operations.",
        "excerpt":"Introduction &amp; Scope When developing a new web service, you may need to do an initial spot test walk through the operations or try to break the service based on the permissible data type values. You could hand craft all the operations, with their respective arguments, into a handful of...","categories": [],
        "tags": ["SOAP","testing","REST","Python","web services","WSDL"],
        "url": "http://localhost:4000/automated-combinatorial-and-spot/",
        "teaser": null
      },{
        "title": "PCAP-NG reader for .NET.",
        "excerpt":"Introduction &amp; Scope The PCAP-NG file format is used to store network captured data used by great programs like Wireshark. There are several API's available for both Linux and Windows but none that are ported to .NET. I decided to make one for my own use in building a network...","categories": [],
        "tags": ["CLR",".NET","PCAP-NG","C#","networking"],
        "url": "http://localhost:4000/pcap-ng-reader-for-net/",
        "teaser": null
      },{
        "title": "Understanding type theory (Part one: Lambda Calculus).",
        "excerpt":"Series Introduction I initially was going to put this together as a single post but quickly realized that it would be a bit much to try and put all of the information into one post. To make it more digestable, I decided to break it up into separate parts. This...","categories": [],
        "tags": ["lambda notation","lambda calculus","type theory"],
        "url": "http://localhost:4000/understanding-type-theory-part-one/",
        "teaser": null
      },{
        "title": "State behavioral pattern to the rescue.",
        "excerpt":"The Creeping Problem I recently found myself developing a request-response style system, where the lifetime of a request could be interrupted at any moment. For most same process execution, like your average desktop application, this is a concern, but arises more often when dealing with multiple coordinated processes. My case...","categories": [],
        "tags": [".NET","C#","design patterns"],
        "url": "http://localhost:4000/state-behavioral-pattern-to-rescue/",
        "teaser": null
      },{
        "title": "Using CC.NET & Gallio for priority based smoke testing.",
        "excerpt":"Pitfalls in Production Being able to monitor production services for potential errors is critical. Especially if the services are dependant on external resources which may become unavailable or exhibit unexpected behavior. Even if you follow good software development discipline, this is always a source of concern. Think network outages, unannounced...","categories": [],
        "tags": [],
        "url": "http://localhost:4000/using-ccnet-gallio-for-priority-based/",
        "teaser": null
      },{
        "title": "Using type converters for JSON.NET.",
        "excerpt":"Motivation I had these flyweights that added a lot of overhead to the serialization process. They weren't really needed in the serialized payload either. In fact, I could recreate the flyweight in memory from just a single property on the object. public class FlyweightObject { public string Key { get;...","categories": [],
        "tags": [],
        "url": "http://localhost:4000/using-type-converters-for-jsonnet/",
        "teaser": null
      },{
        "title": "Creating XML based templates in log4net.",
        "excerpt":"Motivation I decided to use log4net for a recent project I had been working on. There is a concept of loggers and appenders. Loggers are composed of appenders and a log threshold. Appenders are consumers of logging information and provide specific implementations (eg. file, email, event log, database). You can...","categories": [],
        "tags": [],
        "url": "http://localhost:4000/creating-xml-based-templates-in-log4net/",
        "teaser": null
      },{
        "title": "Log per class pattern.",
        "excerpt":"Rookie Moves Awhile ago, I had originally created a single logger for each service and shared it statically across the application. public static class Log { private readonly static Lazy&lt;Log&gt; instance = new Lazy&lt;Log&gt;(() =&gt; new Log(), true); public static Log Instance { get { return instance.Value; } } }...","categories": [],
        "tags": [],
        "url": "http://localhost:4000/log-per-class-pattern/",
        "teaser": null
      },{
        "title": "Get Windows Service name from executable in PowerShell.",
        "excerpt":"I was recently putting some PowerShell scripts together for deployment and maintenance of software to our machine instances. One of the requirements was to be able to discover the service name from a Windows Service executable that uses ServiceInstaller. I needed to be able to extract this value in a...","categories": [],
        "tags": [],
        "url": "http://localhost:4000/get-windows-service-name-from/",
        "teaser": null
      },{
        "title": "Streaming UUEncoder in .NET.",
        "excerpt":"Flashback The last time I used Unix-to-Unix format (AKA UUEncoding) was when USENET was still the big thing and Mosaic web browser was just coming out. That was until recently, when I had a requirement to encode and decode this file type. Searching for an Implementation Since Base64 has largely...","categories": [],
        "tags": [],
        "url": "http://localhost:4000/streaming-uuencoder-in-net/",
        "teaser": null
      },{
        "title": "C++ Memory Semantics for C# and Java Devs",
        "excerpt":"When I first started using C++, I was really confused as to how to pass things around and reason about best practices for memory. In C#, primitives were passed by value and all else by memory reference (ignoring nuance). C++ was a whole new world of aliases, pointers, smart pointers,...","categories": [],
        "tags": ["C++"],
        "url": "http://localhost:4000/cpp-memory-semantic-for-csharp-java-devs/",
        "teaser": null
      }]
