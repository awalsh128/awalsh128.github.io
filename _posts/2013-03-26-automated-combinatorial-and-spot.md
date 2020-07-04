---
layout: posts
title: Automated combinatorial and spot testing of web service operations.
date: '2013-03-26T21:21:00.003-07:00'
author: awalsh128
tags:
- SOAP
- testing
- REST
- Python
- web services
- WSDL
modified_time: '2013-03-26T21:21:59.669-07:00'
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-2541459059581663781
blogger_orig_url: https://awalsh128.blogspot.com/2013/03/automated-combinatorial-and-spot.html
---

### Introduction & Scope

When developing a new web service, you may need to do an initial spot
test walk through the operations or try to break the service based on
the permissible data type values. You could hand craft all the
operations, with their respective arguments, into a handful of URLs but
that would seem pretty inefficient. I found myself in a similar
situation and wanted a programmatic way to walk through the service
operations with a specific input data set. To be clear, I am not
attempting to recreate a [full web service testing
application](http://www.soapui.org/) but rather a simple script to spot
check responses and catch any bugs in a web service endpoint\'s handler.

### Investigating the WSDL

We can automatically flesh out our operations and the message data types
by leveraging the endpoint\'s [WSDL](http://www.w3.org/TR/wsdl). In my
case, I was specifically interested in the [request/response
operations](http://www.w3.org/TR/wsdl#_request-response) available under
the [HTTP GET verb](http://www.w3.org/TR/wsdl#_http). We can get the
parameter names and argument types by looking at the [types
section](http://www.w3.org/TR/wsdl#_types) and then the actual
operations under a WSDL binding that includes an HTTP binding element
with the verb attribute value of GET.

Fortunately, I am dealing with input messages using just the [built in
data type schema](http://www.w3.org/TR/xmlschema-2/#built-in-datatypes)
provided by the WSDL specification. This means that no complex types are
involved and the testing input domain is somewhat simplified. Also, most
of the web service operations use a standard set of parameter names such
that I am able to create a smaller data set of inputs based around them.

### The Code

Your modifications would be to the test\_args dictionary. You can
specify a wide range of different arguments to feed your operations by
parameter names. The service I was testing against used many of the same
parameter names and corresponding domain.

### Conclusion

Thrown together, the script provides an easy way to spot test a web
service by automatically processing the WSDL for a particular binding
and running those bound operations against a provided set of input
messages for it.

### More Reading & Resources

-   [Wikipedia: Web Services Description
    Language](http://en.wikipedia.org/wiki/Web_Services_Description_Language)
-   [MSDN: Understanding
    WSDL](http://msdn.microsoft.com/en-us/library/ms996486.aspx)
