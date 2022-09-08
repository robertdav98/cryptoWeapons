# cryptoWeapons
The goal of this project was to create a unique NFT collection. 
At first the NFTs are minted normally (for a fee). Thereby 12x12x12 (all bows, all strings, all arrows) possible NFTs are available.
Afterwards they can be improved by starting an "Enhancement-Process". A small fee has to be paid and there is a certain probability that it will work.
If it works, the NFT gets better, which changes the background and the frame.
Each weapon starts with +0 and the maximum is +5. The higher the current level, the lower the probability of success.

# Examples

<table>
  <tr>
    <td><img src="https://github.com/robertdav98/cryptoWeapons/blob/main/ExampleFromStartToEnd/0NORMAL.png" alt="0"></td>
    <td><img src="https://github.com/robertdav98/cryptoWeapons/blob/main/ExampleFromStartToEnd/0RARE.png" alt="1"></td>
    <td><img src="https://github.com/robertdav98/cryptoWeapons/blob/main/ExampleFromStartToEnd/0SUPER_RARE.png" alt="2"></td>
    <td><img src="https://github.com/robertdav98/cryptoWeapons/blob/main/ExampleFromStartToEnd/0ULTRA_RARE.png" alt="3"></td>
    <td><img src="https://github.com/robertdav98/cryptoWeapons/blob/main/ExampleFromStartToEnd/0HYPER_RARE.gif" alt="4"></td>
    <td><img src="https://github.com/robertdav98/cryptoWeapons/blob/main/ExampleFromStartToEnd/0LEGENDARY_RARE.gif" alt="5"></td>
   </tr> 
   <tr>
    <td>+0</td>   
    <td>+1</td>  
    <td>+2</td>
    <td>+3</td>
    <td>+4</td>
    <td>+5</td>
   </tr>
  </td>
  </tr>
</table>


# Technology
The NFTs were written as a Smartcontract in Solidty. Since no randomization is possible in Solidity, ChainLink was used (https://chain.link/). Thus a real randomization for the improvement process is possible.
Besides Solidty, many auxiliary components with Python and heaps of frameworks were used (Brownie, Truffle, Ganache, Remix, etc.).
Pinata (https://www.pinata.cloud/) was used to host the images.
