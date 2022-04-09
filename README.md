# Valid-Ready Handshake

This is a Verilog implementation of classic valid-ready handshake protocol broadly used for module interaction. In my implementation, a top module consists of abstract number of **nodes** connected one by one for a stream style processing. It can also be viewed as a "master-slave" model where one node plays the role of a master and the other plays the role of slave. If there exists a sequence of nodes, then the head node only functions as a master, the tail node only functions as a slave, and each middle node both functions as the slave of its upstream and the master of its downstream. 

In the `/src` folder I implemented four types of nodes with small difference:

- if you assume the valid from master is asynchronous and decide to synchronize valid signal by one cycle, then also buffer the input data for one cycle to ensure that the phase of valid signal and input data match.
- Also, if you assume the ready from slave is asynchronous and decide to synchronize ready signal by one cycle, then also buffer the output data for one cycle to ensure that the phase of ready signal and output data match.
- For the second case, it is necessary to buffer the output data because internal storage may be changed by the upstream node.