---
title: "一段阿里笔试代码的（瞎）分析"
date: 2018-10-11 13:57:00 +0800
last_modified_at: 2018-10-11 14:02:47 +0800
math: true
render_with_liquid: false
categories: ["程序人生", "其它"]
img_path: /assets/img/posts/2018/10/11/2018-10-11-yi_duan_a_li_bi_shi_dai_ma_de_xia_fen_xi/
---

## 前言

> 我是菜鸡，如有不对的地方烦请指正。

## 起始

上周（好像是上周）的时候操作系统的老师抛出了一个问题留给我们：

> 对以下程序在一台主流配置 的PC上，调用f(36)所需要 的时间大概是多少？请给出时间估算的依据并对程序的执行情况进行详细的解析说明。
```cpp
int f(int x) {
	int s = 0;
	while (x++ > 0) s += f(x);
	return std::max(s, 1);
}
```

## 第一反应

显然在栈资源无穷且使用超算的情况下，这个递归的寿命会比银河系的寿命（140亿年，我查的）还要长，因为总规模为$2^{2^{31}-36}$。
但题目要求考虑实际情况，所以考虑一些别的东西。

## 注

以下所有（瞎）分析建立在忽略编译优化及`O2`优化的情形下。

## 硬件资源

抛开四万块起步的**iMac Pro**（**128GB**内存和**18核**超线程Xeon），现在主流PC配置普遍是**16GB**内存和**6核12线程**的**i7 8700k**（暂不考虑刚发布的9700k，因为还没有流片）或**8核16线程**的**Ryzen 7 2700k**。

但是！其实用什么CPU都无所谓，因为单纯地执行这个程序实际取决于内存和硬盘的一些参数和CPU的单核运算性能，而且由于操作系统的存在，只要不是上个世纪的电脑，实际运行中都不会对这个程序的运行时间产生多大的限制。

一般来说，在算法竞赛中普遍认为CPU的时间复杂度上界为$10^9\ times/sec$，实际上要低于这个，大概$5\times10^8\times \log_2(5\times10^8)$是极限了（我在`Codeforces`和`NowCoder`测试了$5\times10^8$的快排以得到这个数据）。

## 代码（瞎）分析

对于每一次调用，它都会重复调用自己$2^{31} - 1 - x + 1 = 2^{31} - x$(次)，试图画一下递归树：

![操作系统作业.png][1]

其中：每个节点上的数字`x`代表调用一次`f(x)`，可见，从树根开始，第一层有$1$个节点，第二层有$2^{31} - 36 = 2147483612$个节点，第三层有$\sum_{i=1}^{2147483611}i$个节点，其真值为$\frac{2147483612 \times 2147483611}{2}\approx2.30\times 10^{18}$，第四层的节点总数为$\sum_{i=1}^{2147483611}\sum_{j=1}^{i}j = \sum_{i=1}^{2147483611}\frac{(i+1)\times i}{2}$，这个式子我不太会估值，队友说很easy（Orz）。

但是一层一层的算节点个数并不符合实际情形，虽然这样能比较容易地计算树的实际规模，但是这不满足深搜树的实际增广时的行为。

对于深搜树来说，一条树链的最大长度$L$等于树的高度，同时也是深度$depth$，也就是说在内存中最多只能同时存在$2147483611$个这样的递归子程序，我们来粗略计算一下它需要的内存资源。

取变量$s$和$x$的内存占用（8字节）作为单个子程序的内存占用，那么实际占用的资源约为$2147483611 \times 8 \div 1024 \div 1024 \div 1024 = 16.00745030492544(GB) \approx 16(GB)$，也就是说需要`16GB`的栈大小。

但是！`Linux`下的栈大小大约为`8MB`（比`8MB`小一点），~~垃圾~~`Windows`更是少得可怜，所以到这里没有继续（瞎）分析下去的必要了。

## 结论

这个递归程序在爆栈之后就会立刻结束，所以说在写入大概$10^6$次之后程序就会结束，忽略递归的调用时间理论上应该在$\frac{1}{1000}$秒左右，但因为递归调用的存在，实际情况要大一些，但凭经验判断理应在$1$秒以内，这里不再做深入的探究。

## 能否让这个程序健康地运行

答案是可以的，可以用全局栈来模拟递归调用，这样物理内存有多大程序本身就可以用到多大的内存，此时如果你的内存足够大，则取决于CPU的单核运算性能，如果内存小于`16GB`，那么会发生内存交换，由于木桶效应的存在，此时程序的运算速度就会收到硬盘读写速度的制约。

## $2^n$树的规模证明

首先，可以将上文中提到的深搜树剪为一颗左偏深搜树：

![操作系统作业 (1).png][2]

对应的代码如下：
```cpp
int f(int x) {
	int s = f(x);
	while (x++ > 0);
	return std::max(s, 1);
}
```

易知，这棵树的整体规模为$\sum_{i=1}^{(2^{31}-36)}i$，推广到原树上，每过一层就会多一层$\sum$，显然，$n$层这样的$\sum$逼近于$2^n$。

证毕。


  [1]: cao_zuo_xi_tong_zuo_ye_.png
  [2]: cao_zuo_xi_tong_zuo_ye_1_.png