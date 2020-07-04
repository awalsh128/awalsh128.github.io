---
layout: posts
title: Namespaces for classes.
date: '2011-07-22T09:34:00.000-07:00'
author: awalsh128
tags:
- class namespace
modified_time: '2011-10-16T03:02:57.202-07:00'
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-6028902471672846604
blogger_orig_url: https://awalsh128.blogspot.com/2011/07/namespace-within-classes.html
---

When designing classes for outside use (eg. API) or as a library
component for multiple applications, readability and easy element
(field/function) selection is important. No developer likes hunting
around for fields or functions; a legible and hierarchical organization
of elements aids quicker turnaround time in code delivery.\
\
In some cases, a large class is needed that can possibly contain dozens
or hundreds of elements. Naming convention can aid in this organization
(ie. using common prefixes in field/function names) but are not inherent
to the grammar of languages. Therefore, no semantic advantage can be
taken from using these conventions.\
\
`class Store   ItemList clothingMensShirts   ItemList clothingMensShoes   ...   ItemList clothingWomensShirts   ItemList clothingWomensShoes   ...   ItemList hardwareToolsWrenches   ...   ItemList hardwareMaterialsWood   ...   ItemList electronicsGamesPCFallout3Copies   ...   ItemList electronicsAudioHeadphones   ...`\
\
The current solution to the management of large classes is by using
publicly exposed nested classes.\
\
`class Clothing inherits Department   ClothingSection mens   ...class Mens inherits ClothingSection   ItemList shirt   ItemList shoes   ...abstract class Store   ...   Department clothing   ...class IKEA inherits Store   ...IKEA newYorkStore = new IKEA();newYorkStore.buy(newYorkStore.clothing.mens.shirts[0]);`\
\
This is a possible solution but also comes with it\'s own problems.
Encapsulation of the nested class will not only hide information from
the public user but also from the parent class as well. This can be
problematic when designing an abstract class where the functions, that
must be implemented, must also access non-public elements inside the
nested. For example, in the store example, any data the top level class
(Store) may want to access from the lower level ones (ClothingSection,
ItemList) will be unavailable if that data must also be hidden from the
public user.\
\
Also, the nested classes cannot be abstracted to require implementation
from any inheriting class. Revisting the store example, this means that
abstracting the ClothingSection class would require two new classes for
one implementation. Creating not only a child Store but also a child
ClothingSection class.\
\
Nested classes are helpful for creating logical hierarchies within a
class or providing abstract functionality privately inside the class.
Although, I would propose the use of namespacing inside a class instead.
It would provide the logical hierarchy needed in a very simple way and
allow for information sharing across the entire domain of the class. It
would need a separate keyword though to prevent use outside of classes.\
\
`class Storeclassnamespace clothing   classnamespace mens      ItemList shirts      ItemList shoes      ...   ...   classnamespace womens      ItemList shirts      ItemList shoes      ...   ...   classnamespace hardware      classnamespace tools         ItemList wrenches         ...      ...      classnamespace materials         ItenList Wood         ...      ...   ...`
