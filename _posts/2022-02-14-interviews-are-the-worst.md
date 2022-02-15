---
title: Interviews are the Worst
last_modified_at: 2022-02-14 00:00:01 -0700
tags:
- Interview
---

If you have experience in the software engineering field, an interview process can test the experience you have; projects, production scenarios, designs. Unfortunately, for junior positions and those out of college, there isn't much to test for. Since most are computer scientists, you could test knowledge of algorithms and data structures but does that really prove the ability of a candidate? Knowing the upper bound complexity of an algorithm's runtime is important but what about when a constant multiplying factor means the difference between production being up and down. We don't have a solution for the Travelling Salesman Problem but we have very good and practical approximations (e.g. flight scheduling).

As an engineer, we have to think about what is the best approximation and trade offs among different solutions when posed with a hard problem. While the CS field greatly informs software engineering and provides it with a fundamental basis to extend from, it doesn't wholly prepare a junior software engineer for working in the field, especially in the parts that matter the most.

So what does this have to do with interviewing software engineers? Well it's hard because they have little to no experience. That isn't their fault. It is just the difficult situation that interviewers and interivewees find themselves in. What's worse is that there are good jobs out there but the candidate ends up having a terrible interviewer.

## Dynamics

![Stackoverflow Job Interview](/assets/img/2022-02-14-interviews-are-the-worst/job-interview-stackoverflow.jpg)

As someone that has given many interviews, my worst nightmare is leading the candidate down a road I can't pull them out of due to a bad question or guidance. For me the worst feeling is holding an interview that wastes the candidate's time and the opportunity to accomplish their career goals. As an interviewer it is my responsibility that the problem be clear to the candidate and something that reflects actual skills needed.

### Lack of Consistent Feedback

I have had interviewers go out of the room to take a bathroom break, sit on their phones, or just stare silently while I worked on the problem. An interview is just as much a chance to see how the candidate would work with you as you them. It is also an opportunity to evaluate their teamwork skills. This kind of work is not an island and having a poor team dynamic can ruin projects.

Another problem is when the interviewer lets you hang yourself with your own solution. It is important that the interviewer provide guidance and redirection. Not doing so wastes the entire time left instead of giving a candidate an opportunity to show what they can do after correction. I had an interview with a principle engineer once for their architecture interview (they break them up into categories). In it they asked me to find a way to count the number of unique exceptions in a production system. I went right into showing an architecture of designing a logging system and how the processing would work at scale. They had a line of questioning talking about the logging system itself and then at the end told me I could just hash the exceptions. I was pissed. If the interviewer had told me it would be a simple data structures question I would have answered it right away but was completely misled about the parameters of the interview. It was my fault that I made a simple solution a complex one, but the opportunity was completely missed on seeing what I could do, even if that meant I got marked down.

### Toy Questions

IMO the worst kind of questions are the ones that don't reflect real work at all. How is reversing a linked list or rotating a matrix going to show that I am a good engineer? Some people say that this just reveals how you think about things and while there is some merit to that, it can be very perilous. It requires the candidate to be well studied in these problem spaces first. A better question reflects not only how they approach something but the problem they are trying to solve. What compounds this problem is when an interviewer has a single toy question they ask all the time and evaluates performance based on their own long time familiarity with the problem. The worst is when the problem requires just one key observation to solving it.

### Poor Personality

I have high anxiety and have had interviews go terribly wrong. This is also why I try really hard to improve myself in the process and be an interviewer that gives the candidate the best opportunity of proving themselves. I have co-workers and friends that I consider to be very high quality engineers that would never had the chance if someone didn't accommodate them in terms of personality.

So what do I mean by poor personality? The interviewer has the power to make or break in these situations. Imagine some of the difficult people that you had to deal with in your life. Now have them be your interviewer. Dispassionate, judgemental, uncooperative, critical, the stuff of nightmares.

### Feedback Goes Both Ways

If you have an interviewer like this don't be afraid to call it out afterwards. Some of these kind of interviewers may score you well but they should be getting feedback that this isn't how to handle it. Be polite but be pointed about the behavior. It may not matter but many companies want this kind of feedback. At the end of the day, any person committed to wanting great candidates cares about the process that gets them to that.

## It's Not All Bad

For the bad interviews that I have had or heard about, there are plenty of, if not more, good ones too. The interviewers were attentive, guiding and gave problems that were multi layered and facetted. Some of them I came out wanting to be on their team because the collaboration went so well.

The reason I call out the bad interviewers is because candidates tend to put the blame on themselves. There is plenty that can be done to make sure you pass an interview but it is important to know what to look for too. Who wants to work for a company whose values are reflected in their employees this way? The process is as much about you evaluating them as they you and a good interviewer should know this. Although this isn't a blame game either. Even a bad interviewer could be the gatekeeper to a great job and you will never have to see them again after being hired.

## How Should I Prepare

The bad interviewer is a caracature. An embodiment of all the things that could go wrong. Really most have a mix of qualities both positive and negative, intentional and not. You will just have to make sure you do well in spite of the circumstances given.

**Become a data structures and algorithms gymnast.** I call it this because it is the most rote part. It bites some candidates because they just didn't do the work. Like a gymnast you need a bunch of practice and be able to contort yourself in different ways because every problem will be some variation.

### Problem Spaces

What is the problem that is trying to be solved more generally speaking? A problem space doesn't refer to any specific solution but rather the end goal that needs to be met. If you become familiar with these, you can also identify some of the common components that are used to solve them. Below is an approximate sample of the problem spaces out there.

#### Strings

For example, in bio-informatic key sequencing, the problem space is in looking for specific patterns (e.g. genome sequencing). Most all sequences can be represented using a string abstraction. While the example of key sequencing is a real world example, in can be generalized to ask questions about strings. The generalized problem space would be strings. By strings I don't mean words or text, I mean a sequence of symbols in the most abstract way.

![Gene Sequence](/assets/img/2022-02-14-interviews-are-the-worst/gene-sequence.png)
*Excerpt of a Gene Sequence*

Given the string problem space, some combinatorial factors, with examples, could be length, affix, repetition, similarity, and cardinality. Combinations of those being:

* Least common subsequence.
* Largest common prefix.
* Most unique string.
* Longest repeated string.
* Number of unique characters (i.e. cardinality).
* Words that share the most characters.

This is just a small example. Least common subsequence is a popular one but why stop there? If you can do the combinations then you will have mastery. Just remember an interviewer is trying to mix it up too.

#### Encoding

![Founder of Information Theory](/assets/img/2022-02-14-interviews-are-the-worst/claude-shannon.jpg)
*Claude Shannon - The OG of Information Theory*

How would you represent data in memory? Combinatorial factors could be cardinality, word size, and direction. Some combinations:

* Number of unique values encountered.
* Counters of letters encountered.
* Compression for streaming data.
* Compression for bounded data.
* Record a sequence of values containing A, B and C.

#### Lookup

What is the best way to lookup data with the constraints given? Combinatorial factors could be cardinality, length, and match type (whole, partial).

* Specific string of unbounded length.
* Strings that share the first 3 characters.
* Specific count of a single character in a corpus.
* Words who share the same 3 letters.

Notice how there is some overlap here with strings, that is because lookup frequently is a subset of the string problem space. We could easily apply common solutions from the string problem space to these as well as hashing and graphs (i.e. trie).

#### Graphs

![Spotting Spammers in Social Graphs](/assets/img/2022-02-14-interviews-are-the-worst/spammers-in-social-graphs.jpg)
*Spotting Spammers in Social Graphs*

How do you find specific relationships between entities? Combinatorial factors could be value cardinality, size, edge direction, edge weights and cycles.

* Least cost path between two points.
* Detect all cycles.
* All paths to a point from all other points.
* Paths that never leads to a cycle.
* Reverse direction to every odd numbered node and detect all cycles.
* Remove edges in a cycle that would have the most cost.

Keep in mind that a linked list and tree are just graphs with constraints. If you learn graphs, you learn trees and linked lists. It's just with trees their is direction so it can be flipped.

#### Sorting

How do you derive meaning (how is it practical?) by ordering some collections of values? Combinatorial factors could be value cardinality, stability, partiality, and comparability.

* Group cards by color.
* Sort integers by partial order where some integer k can be 4 positions away from k+1 and k-1.
* Sort a stream of natural numbers.
* Group floats by their whole number and the order they appear (stable).
* Order a deck of cards by rank, color and suit.

#### Dynamic Programming

Honestly I don't study this and despise its use in interviews. Rather jadedly I would speculate that most interviewers wouldn't even be able to come up with a DP solution from first principles. Identifying optimal sub-structure really just takes a lot of experience IMO. Much like induction proofs.

I find a better approach is to work a real world problem from several solution approaches and then use the DP method intuitively. This comes after really understanding the problem and consequently its sub-structure when applied in successive steps (either iteratively or recursively).

#### Space &amp; Runtime Are Cross Cutting

For all of these problem spaces, it is important to factor in time and space complexity as well. For example, merge sort is best suited for space because the re-ordering happens in blocks. However quick sort is considered the most performant for in-memory on average even though quick sort has the largest worst case. For lookups a bounded set of keys could just use an array (e.g. frequency counting letters).

Bonus points for pointing out engineering ramifications for choosing a solution even if it has the same complexity. It may be just a constant multiplier difference (e.g. 4n and n) but it could mean the difference of thousands of dollars in a production system's resource usage.

### Think Out Loud

While going through your thought process, make sure you share it with the interviewer like you would in a job. It's like spreading out your ideas on a table, picking each one up, investigating it, saying what the pros and cons are, and then going with the best candidate at the moment while also being open to improvement. Maybe your idea isn't the best one but put something out there that you can execute on and refine later. This will give an opportunity for the interviewer to see how you approach problems and judge the qualities of it.

### Ask A Lot Of Questions

Really ask them. The worst scenario is that you assume too much and go down a bad path. Probing the problem shows that you are thinking about all the possible aspects and applying critical thinking. I have had candidates ask questions that I didn't even ask myself about the problem (impressive). In my experience, the better candidates were very inquisitive. Be curious and learn more.

### Think Before You Type

Maybe you're nervous, maybe you think you know the answer and you go straight to typing. Stop! Don't do it. I have been guilty of this myself. Writing code is a matter of self expression for me, a way of speaking. Although I have learned in time that it can also be a way to code yourself into a corner or hit a dead end that requires lots of back tracking and deletion of code. It can also be a bad sign that you are a coder that doesn't think before you act and can potentially waste large hours of time on bad paths. This is why design is highly valued in software engineering. It forces people to think about the hard problems before they run up against them in code. Same applies to an interview. I have seen candidates rush into a problem only to stop and realize they really didn't understand it. Don't do this. Stop and go over you design with the interviewer. Walk through the different approaches, considering each and the selecting the route you want to take. This complements the idea of thinking out loud.

### Practice Coding .. A LOT

When walking through mock interviews, always write out your solutions. In this COVID world, that means typing on a keyboard but it doesn't hurt to do both. Especially if you get called up for an in-person interview.

#### Pick a Language

Don't pick a language you think they would want you to write, pick one you are good at and know how to use both syntactically and idiomatically. Unfortunately there are companies that want you to code in a specific languages. Personally I think that is a poor choice on the company since they should be looking for talent but sometimes that's just the way it goes. Personally I would pick Python because it is the easiest to write IMO. Whatever language you end up picking, always code out the solution. It will build up that muscle so you can easily translate your ideas to code quickly.

#### Break Up the Problem

Start top down. Meaning start with the top level function and then break up the problem into sub functions. Deal with easy ones first and then slowly work your way towards the hardest. A divide and conquer approach shows you can compartmentalize and break out the problem into sub problems. It is something that is impressive and a lot of candidates don't do.

```python
def solve_problem():
  easy_values = solve_easy_subproblem()
  hard_values = solve_hard_subproblem()
  return do_trivial_thing(easy_values, hard_values)

def solve_hard_subproblem()
  easypartofhard_values = solve_easypartofhard_subproblem()
  somewhathard_values = solve_somewhathard_subproblem()
  return do_code_timeconsuming_thing(easypartofhard_values, somewhathard_values)
```

An additional upside to this is that if you don't complete the solution in time, the interviewer is able to at least evaluate the parts that you wholly finished. This is especially helpful if you solved the most conceptually hard parts but just didn't have enough time for the time consuming code part.

### Manage Your Emotions

For some interviewing is not emotionally taxing but for others it can be debilitating. Personally this is a big problem for me. I froze up completely for an interview once. I couldn't even answer a trivial problem. I was so panicked that I couldn't even think straight. The interviewer was very kind about it all but there was nothing to evaluate, I failed. Some things that helped me:

* **Practice until it is instinctual.** Do gymnastics until you can cooly answer any interview question or at least get close to it. Interview problems are just combinations; if you learn the fundamentals and apply them in different arrangements, they aren't so surprising.
* **Mock interview a lot.** Have a friend or use an online resource to constantly perform mock interviews. It will help you with anxiety if you have it and keep you accustomed to the interview format. When I have held mock interviews I have intentionally been cold but polite. It wasn't to be mean but to prepare them. If you have different tiers of jobs you are interested in, interview with the lowest ones first. Less is on the line if you fail and it is the best thing because it is real.
* **You can always try again.** Most companies allow a candidate to try again after some time has passed. Just because you failed an interview doesn't mean you are a bad candidate. It just means you were off or weren't prepared enough. I'll be honest, I failed my first interview with Google, and thought I wasn't good enough. Five years later I tried again and got the job.
* **You are good enough.** Imposter syndrome is a big thing. Especially when you work with people that you perceive to be intelligent and/or well accomplished. Sure there are people that have an obvious raw high intelligence but in my experience that is not the majority, and even then, very incongruant. Many intelligent people who I have met are highly driven. Education is a large factor in intelligence. Also intelligence is not some monolith; people express their intelligence through different characteristics as I alluded to with the word incongruant. In other words, intelligence is fluid and if you are driven, you are good enough.

## Resources To Use

### Competitive Programming

Sites like TopCoder are nice and a way for you to get your chops solving different problems but it is first and foremost a competitive programming site. It is meant to present challenges that are new and novel, eliciting the tersest amount of code in the smallest amount of time. This isn't to say if you got good at this you wouldn't do well in an interview, the opposite, but it requires you to inuit the ability to solve based on working through a lot of problems rather than learning the underlying problem spaces.

### Interview Question Databases

This pertains to sites like CareerCup where questions are posted that came from actual interviews with tech companies. Keep in mind that a lot of these get posted because they were difficult for the candidate. That means you are more likely to see harder questions and have false expectations of what is required from you. Take these sites with a grain of salt.

### Online Exercises

Online IDEs and sets of exercises that you can drill on are useful (e.g. GeeksForGeeks, HackerRank). I usually pick the data structures and algorithms exercises and just grind on them several times until it becomes second nature. Experiment with different sites and see which one works best for you. The key is that you are able to get through the exercises fairly quickly. A good site should be able to build you up by difficulty so that you can get muscle strength.