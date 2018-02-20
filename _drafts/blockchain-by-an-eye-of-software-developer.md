---
layout: post
title: Blockchain by an eye of software developer
---
Blockchain without any doubt is recently the most frequently used buzzword.
Hype is huge powered by the crazy world of cryptocurrencies. The craziness
of cryptocurrencies is probably the reason why lot of software developers
treat blockchain as something abstract and not interesting. Let's have a
look into a blockchain by an eye of a software developers.

# Debunking myths

A lot of myths has raised and lot of developers
has distorted image of blockchain. I won't go over each myth those can
be found easily on the web. I'll just point out one and most important:
**Blockchain is not a Bitcoin or any other cryptocurrency.**

The common misunderstanding is the difference between blockchain and Bitcoin.
Well blockchain is an underlying technology of Bitcoin but it's not
a Bitcoin nor a cryptocurrency. The cryptocurrencies are just features
build on top of a blockchain. Because of that (and for few other reasons)
blockchain is often being referred as *distributed ledger* to differentiate 
this technology from Bitcoin.

So what is a blockchain? By an eye of a software developer it's a data structure
or a database or both. Well... it's a set of records linked to each other and
stored in a distributed repository. It's hard to have a definition satisfying
everybody as there are many variations of a blockchain and constantly new
are being invented. To understand what blockchain is let's have a closer look
from a software developer perspective.

# Blockchain as a data structure

Blockchain as the name stands is a chain of blocks. So what is a block than?
Block is a chunk of data with accompanying meta information describing it. It can store
pretty much anything from financial operations to binary code that can be executed -
anything we want. Meta information validates the data stored in a block so
that we can be assured the data was not altered. Let's write a simplest script
generating a block.

{% highlight ruby %}
require 'digest'

version = 1
data    = ARGV[0]

stamp = format(
  "%d:%d:%s",
  version,
  Time.now.to_i,
  data
)

digest = Digest::SHA1.hexdigest(stamp)

puts format("stamp: '%s'\ndigest: %s", stamp, digest)
{% endhighlight %}

Let's execute:

{% highlight bash %}
$ ruby block.rb "Hello world"
stamp: '1:1518860302:Hello world'
digest: 52f77718efc94ab98fd7fc9ea0457a467e662af5
{% endhighlight %}

We've got our data and a digest ensuring it's integrity. As a data you
can put literally anything from plain text, JSON to binary data like images,
audio or video files to executable code. Anything you want.

Right now nothing really exciting about the blockchain.
Let's proceed to the next element of a blockchain which is a chain.

In blockchain each block is linked with the previous block. Each except the
first block which is a special block called genesis block. Let's modify our
script allowing the hash of a previous block to be passed as a parameter.

{% highlight ruby %}
require 'digest'

version       = 2
data          = ARGV[0]
previous_hash = ARGV[1]

stamp = format(
  "%d:%d:%s:%s",
  version,
  Time.now.to_i,
  data,
  previous_hash
)

digest = Digest::SHA1.hexdigest(stamp)

puts format("stamp: '%s'\ndigest: %s", stamp, digest)
{% endhighlight %}

Let's execute:

{% highlight bash %}
$ ruby chain.rb "Genesis block" 0
stamp: '2:1518860804:Genesis block:0'
digest: 18567e288de0c22921929a77f3d98f23f91d376b

$ ruby chain.rb "Hello world" 18567e288de0c22921929a77f3d98f23f91d376b
stamp: '2:1518860817:Hello world:18567e288de0c22921929a77f3d98f23f91d376b'
digest: c000f33b51a2c73869543e8b033bbb2ba6408afd
{% endhighlight %}

We've created a genesis block and next we've added new block to a chain
linked to a genesis block. But what exactly we've gained with that?

The reason for this is to make altering the chain harder. If more blocks are
added on top of a block I've added in order to change my block attacker must
recalculate digest's for my block and all blocks added on top of it since my block
is a parameter for calculations of further blocks. If attacker wouldn't recalculate
all necessary blocks it can be quickly identified that chain was tampered.

So if 1000 blocks were added on top of my block how hard for an attacker would be
to change my block? Well let's add another block and see:

{% highlight bash %}
$ time ruby chain.rb "New block" c000f33b51a2c73869543e8b033bbb2ba6408afd
stamp: '2:1518861367:New block:c000f33b51a2c73869543e8b033bbb2ba6408afd'
digest: 1e09ba553668d19079d4ce5d718fc271464fca0e
ruby chain.rb "New block" c000f33b51a2c73869543e8b033bbb2ba6408afd  0.08s user 0.04s
system 48% cpu 0.235 total
{% endhighlight %}

I've added new block on top of my previous block. It took 0.235s to calculate it.
Hold on here for a minute. Recalculating 1000 blocks would take 235 seconds!
With a simple ruby script! I'm sure motivated hacker can do way better than that. Where
is that legendary blockchain security everybody is talking about?

# Proof of work

Ok so we have a problem. We link next block with a previous block but we aren't
getting anything out of that. Calculating a hash is so fast that with any computer
we can easily hack the whole chain. How to get it more secure then?

So the problem is that we're ensuring integrity of our chain with simple hash code
that can be computed very fast. The fast computation is necessary as we need to be able
to verify integrity in an instant. We can't afford perform costly computations in
order to verify data - that would be counter productive. If only we could make it
hard to generate new block but make it effortless to verify it's correctness.
If only we could do something like that.

Something like that already exists and is called [Hashcash][1]. It is a
proof-of-work algorithm developed to limit email spam and denial of service
attacks. The idea is very simple each email has to include special header for
which hash was starting with certain amount of 0's. Since you can't predict
the outcome of a hash function you need to randomly modify the header so that
it's hash matches the requirements. It's hard to generate but easy to verify and
it basically proves that computing power was spent when generating a block.

Let's modify our script so that it generates hashes starting with certain amount
of 0's.

{% highlight ruby %}
require 'digest'

version       = 3
data          = ARGV[0]
previous_hash = ARGV[1]
difficulty    = ARGV[2].to_i

nonce         = 0

begin
  stamp = format(
    "%d:%d:%s:%s:%d",
    version,
    Time.now.to_i,
    data,
    previous_hash,
    nonce += 1
  )

  digest = Digest::SHA1.hexdigest(stamp)

  print digest + "\r"
end until digest.start_with?('0' * difficulty)

puts format("stamp: '%s'\ndigest: %s", stamp, digest)
{% endhighlight %}

In this script we regenerate blocks as long as it's hash doesn't start with given amount
of zeros. We're doing that by appending a nonce to the hashed data. We're trying
to guess the value for which hash is going to have specified amount of zeros.
The more zeros at the beginning we expect the more difficult it's to
generate a valid block. Let's have a look:

{% highlight bash %}
$ time ruby hashcash.rb "Hello world" 18567e288de0c22921929a77f3d98f23f91d376b 4
stamp: '3:1518906615:Hello world:18567e288de0c22921929a77f3d98f23f91d376b:36829'
digest: 0000a8e2383121c83af44b03c2182f038c6de27f
ruby hashcash.rb "Hello world" 18567e288de0c22921929a77f3d98f23f91d376b 4  0.39s user 0.09s system 79% cpu 0.611 total

$ time ruby hashcash.rb "Hello world" 18567e288de0c22921929a77f3d98f23f91d376b 5
stamp: '3:1518906629:Hello world:18567e288de0c22921929a77f3d98f23f91d376b:1445615'
digest: 00000e0d26fbec9491624af44b70480e22913f8e
ruby hashcash.rb "Hello world" 18567e288de0c22921929a77f3d98f23f91d376b 5  8.80s user 1.74s system 92% cpu 11.395 total

$ time ruby hashcash.rb "Hello world" 18567e288de0c22921929a77f3d98f23f91d376b 6
stamp: '3:1518906650:Hello world:18567e288de0c22921929a77f3d98f23f91d376b:1984015'
digest: 000000d8edbddbc8f63b6cde64ebce3124a14e7e
ruby hashcash.rb "Hello world" 18567e288de0c22921929a77f3d98f23f91d376b 6  12.40s user 2.47s system 94% cpu 15.783 total
{% endhighlight %}

Hash with 4 zeros was generated in 0.6 second, with 5 zeros in 11 seconds with 6 in 15.
By setting the amount of required zeros we can adjust the frequency of new blocks
being added to the chain For example Bitcoin adjusts the difficulty in a way that new
block is added in average every 10 minutes.

# Mining

In real world block needs to have a hash starting with way more than 4 or 5 zeroes.
At the moment of writing this post Bitcoin block starts with 18 zeros. You need a substantial
computing power to generate such block within a reasonable time. That is actually
a reason why blockchains are so hard to modify. If hacker wants to modify a block he'd
need to modify all blocks on top of it (and convince other nodes that his version of
a chain is actual). It would take a lot of time and resources to do so for a single
person and for sure new blocks will be added to the chain while he'll be recalculating
his version.

Therefore the concept of miner was introduced to the blockchain. Basically miners are
volounters offering their computing power in order to find a proper nonce giving
a block with desired hash. There may be different conditions under which block is valid,
hash starting with zeros is just one example (and popular one) but it could be anything.
Miners are receiving gratification for their effort. In cryptocurrencies world it's usually some
fee assigned with a transaction but it can be anything. Miners can be paid
with real money as well.

The network of miners collectively are providing such computing power that within
a blockchain network new blocks can be mined in a reasonable time. By adjusting a difficulty
it's possible to control how often new blocks are added to the chain.

# Distributed Ledger

Another aspect of blockchain security is distribution. By distribution we understand that
there is no one central authority. Copies of a blockchain are distributed across all nodes
within a network. That introduces a few problems.

When adding a new block to the chain, nodes need to agree that particular block is valid and
will be added as a next block. This problem is called a [consensus problem][2] and there are few
strategies how to solve it. Usually there is some threshold that if for example more than 50%
of nodes agree that block is valid it is added to the chain and new version of chain is
distributed across a network.

[Consensus algorithms][3] are a broad topic and I'd look onto them in future posts.

# Conclusion

In this post I've only touched the surface of a blockchain topic. The main take away should be
that for a software developer blockchain is like a data structure or repository. It has nothing
to do really with cryptocurrencies as most people think. It is a way of storing a data or records
in a distributed network with a few clever tricks making it more secure than ordinary ways
of storing data. It can be brought even further as stored data may be something executable
allowing software developers to develop decentralized, distributed applications.

Understanding a very basics of a blockchain should put more light on what it is and how this
technology can be utilized (and that it has nothing to do with speculation on BTC).

[1]: https://en.wikipedia.org/wiki/Hashcash
[2]: https://en.wikipedia.org/wiki/Consensus_(computer_science)
[3]: https://en.wikipedia.org/wiki/Consensus_algorithm
