# Tendermint  

　　Tendermint是一个能够在不同机器上，安全一致复用的应用软件。Tendermint框架设计是将区块链应用与共识进行分离，其框架示意图如下图所示。Tendermint框架
可分为Tendermint Core和ABCI (Application BlockChain Interface)两部分，其中Tendermint Core是Tendermint的核心，实现共识与数据传输；ABCI是
Tendermint Core与区块链应用的接口。 Tendermint支持开发者们使用不同语言开发各自的区块链应用，无需考虑共识和网络传输的实现。  
![](https://github.com/ChenypZJU/seminar/blob/master/7.cross-chain-cosmos-tendermint/notes/pictures/tendermint%E6%A1%86%E6%9E%B6.jpg=300*300)　　

　　在本文中，会先介绍由tendermint搭建的区块链中的数据结构，再介绍tendermint框架中的tendermint core，其中包括tendermint的BPOS的共识过程、锁定机制以及PoLC等，最后将介绍tendermint core如何利用ABCI与应用进行交互。
 ## 数据结构  
 ### Block  
 
 　　在tendermint中，Block结构如下图所示。  
   ![](https://github.com/ChenypZJU/seminar/blob/master/7.cross-chain-cosmos-tendermint/notes/pictures/block.jpg)  
   在`Header`中，记录当前区块基本信息的有:  
   `Version`: 包括app version和tendermint version  
   `ChainID`: 区块链名称  
   `Height`:该区块所属高度  
   `Time`:出块时间  
   `NumTxs`：当前区块打包的交易数  
   `TotalTxs`:该区块之前所有区块（包括当前区块）打包的交易数  
   同时也记录了前一区块的信息：  
   `LastBlockID`:前一区块的BlockID,包括了前一区块的header的merkle根hash值以及包括了上一区块序列化分块的merkle根hash值  
   还有关于前一区块的确认和执行结果：  
   `LastCommitHash`:validator set关于上一区块的投票`LastCommot`的merkle根hash值（Simple Merkle root）  
   `LastResultHash`:上一区块交易执行后结果的merkle根hash值  
   关于共识的相关信息：  
   `ValidatorsHash`:当前区块的验证者集merkle根hash值  
   `NextValidatorsHash`:下一区块的验证者集merkle根hash值  
   `ConsensusHash`:当前区块amino编码的共识参数的hash值  
   关于当前区块内容的有：  
   `EvidenceHash`:记录当前区块中验证者恶意行为的Evidence的merkle根hash值  
   `DataHash`：当前区块打包交易的merkle根hash值  
   `ProposerAddress`:当前区块打包者(proposer)的地址  
   此外，还有表示应用状态：  
   `AppHash`：应用确认和执行上一区块返回的任意字节数组，表示应用状态，用于验证应用提供的merkle proofs。  
   以上是对Block区块包含数据的简要介绍，具体详见![tendermint:block](https://github.com/tendermint/tendermint/blob/master/docs/spec/blockchain/blockchain.md)  
   ### State  
   在Tendermint区块链中，交易执行结果、验证者、共识参数等并没有直接存储在区块block中，而是将其存储在了数据结构State，而State则存储在应用中。当tendermint core需要相应的参数时，通过ABCI接口向应用（application）获取这些信息。State的结构如下图所示：  
   ![](https://github.com/ChenypZJU/seminar/blob/master/7.cross-chain-cosmos-tendermint/notes/pictures/state.jpg)  
   其具体参数解释可见![tendermint:state](https://github.com/tendermint/tendermint/blob/master/docs/spec/blockchain/state.md)  
   ### Block与State中数据联系  
   　　下图表示了Block和State中各数据之间的联系。Note:BlockID并不只有`Header`的Merkle Root。  
       
       
   ![](https://github.com/ChenypZJU/seminar/blob/master/7.cross-chain-cosmos-tendermint/notes/pictures/%E5%8C%BA%E5%9D%97%E6%95%B0%E6%8D%AE%E5%AD%98%E5%82%A8%E7%A4%BA%E6%84%8F%E5%9B%BE.jpg)
   
 ## Tendermint Core  
 Tendermint Core主要实现共识和网络数据传输，其中共识采用拜占庭POS协议。接下来将详细介绍tendermint的共识过程。  
 ### 共识BPOS  
 #### 验证者Validator  
 * 用户可以通过抵押Atom、签署并提交BondTx交易成为验证者Validator。  
 * 验证者具有投票权，投票权大小与抵押的Atom多少相关。  
 * 验证者在共识过程中轮流出块。  
 * 验证者有数量限制，初始为100位，此后每年增长13%，最终达到300位。  
 * Cosmos Hub验证者可接受任何种类的代币或组合作为处理交易的费用，自行设置兑换率。  
 * 对于任何有意或无意的偏离认可协议的验证者, 对其施加一定的惩罚。  
 * 验证者的更改将在更改交易所属区块之后的第二个区块生效。

 #### 成为出块者Proposer  
 验证者根据投票权的比例轮流成为出块者，投票权votingPower越大，其成为出块者的频率越高。验证者出块优先权的计算方式为： 
 ```  
 在R轮：  
 1. 验证者出块优先权=（R-1）轮出块优先权+投票权  
 2. 选择出块优先权最大的验证者为出块者，优先权相同时，按地址排序  
 3. 出块者出块优先权=出块优先权-总的投票权  
 4. 进入下一轮  
 ```  
 以(p1,4),(p2,5),(p3,8),(p4,3)为例，其出块顺序为p3,p2,p1,p3,p4,p2...具体可见![proposer-selection-procedure-in-tendermint](https://github.com/tendermint/tendermint/blob/master/docs/spec/reactors/consensus/proposer-selection.md#proposer-selection-procedure-in-tendermint), ![Tendermint共识之Validator](https://blog.csdn.net/csds319/article/details/81137878)和![validator_set](https://github.com/tendermint/tendermint/blob/develop/types/validator_set.go)  
 
 #### 共识过程  
 
 #### 锁定条件
 
 ### 网络  
 
 ## ABCI
