# SHNU-Exam LaTeX 文档类实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 创建 `shnu-exam.cls` 文档类，精确还原上海师范大学试卷格式。

**Architecture:** 基于 `ctexart` 的 LaTeX 文档类，使用 XeLaTeX 编译。核心功能包括：精确字体/行距控制、自动得分表生成、选择题选项智能排版（4列/2×2/4行自适应）、答题空白区控制。

**Tech Stack:** LaTeX (XeLaTeX), ctex, fontspec, unicode-math, geometry, fancyhdr, tabularx, enumitem, setspace, calc, environ, xparse, etoolbox, lastpage

---

### Task 1: 创建文档类骨架

**Files:**
- Create: `shnu-exam.cls`

- [ ] **Step 1: 编写类声明和选项定义**

```latex
% shnu-exam.cls — 上海师范大学考试卷文档类
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{shnu-exam}[2026/05/17 v1.0 SHNU Exam Class]

% === 类选项 ===
\RequirePackage{kvoptions}
\SetupKeyvalOptions{family=shnu, prefix=shnu@}

\DeclareStringOption[10]{answerspace}      % 默认答题空行数
\DeclareBoolOption[true]{showscore}         % 是否显示得分表
\DeclareBoolOption[false]{solution}         % 是否显示答案

\DeclareDefaultOption{\PassOptionsToClass{\CurrentOption}{ctexart}}
\ProcessKeyvalOptions{shnu}

% 基于 ctexart，10.5pt 基准字号
\LoadClass[10.5pt,a4paper]{ctexart}
```

- [ ] **Step 2: 编写最小验证文件**

```latex
% test-minimal.tex
\documentclass{shnu-exam}
\begin{document}
Hello SHNU Exam
\end{document}
```

- [ ] **Step 3: 编译验证**

Run: `xelatex -interaction=nonstopmode test-minimal.tex`
Expected: 无错误编译，生成 PDF。

- [ ] **Step 4: Commit**

---

### Task 2: 字体和数学字体配置

**Files:**
- Modify: `shnu-exam.cls`

- [ ] **Step 1: 添加字体配置代码**

```latex
% === 字体配置 ===
\RequirePackage{fontspec}
\RequirePackage{unicode-math}

% 中文主字体：宋体 (SimSun)
\setCJKmainfont{SimSun}[
  BoldFont   = SimHei,
  ItalicFont = KaiTi,
  BoldItalicFont = SimHei,
]

% 中文无衬线：黑体 (SimHei)
\setCJKsansfont{SimHei}[
  BoldFont = SimHei,
]

% 中文等宽
\setCJKmonofont{SimHei}

% 西文主字体：Times New Roman
\setmainfont{Times New Roman}[
  BoldFont   = Times New Roman Bold,
  ItalicFont = Times New Roman Italic,
  BoldItalicFont = Times New Roman Bold Italic,
]

% 西文无衬线：Arial (用于特定元素)
\setsansfont{Arial}

% 数学字体：TeX Gyre Termes Math (Times 风格)
\setmathfont{TeX Gyre Termes Math}

% 预定义字体族
\setCJKfamilyfont{zhsong}{SimSun}
\setCJKfamilyfont{zhhei}{SimHei}
\setCJKfamilyfont{zhfs}{FangSong}
\setCJKfamilyfont{zhkai}{KaiTi}

\NewDocumentCommand{\songti}{}{\CJKfamily{zhsong}}
\NewDocumentCommand{\heiti}{}{\CJKfamily{zhhei}}
\NewDocumentCommand{\fangsong}{}{\CJKfamily{zhfs}}
\NewDocumentCommand{\kaishu}{}{\CJKfamily{zhkai}}
```

- [ ] **Step 2: 更新验证文件测试字体**

```latex
% test-fonts.tex
\documentclass{shnu-exam}
\begin{document}
{\heiti 黑体标题} {\songti 宋体正文}

English Text in Times New Roman

数学公式：$E(X) = \int_{-\infty}^{\infty} x f(x) dx$
\end{document}
```

- [ ] **Step 3: 编译验证**

Run: `xelatex -interaction=nonstopmode test-fonts.tex`
Expected: 正确显示黑体、宋体、Times New Roman 和数学公式。

- [ ] **Step 4: Commit**

---

### Task 3: 页面布局和页眉

**Files:**
- Modify: `shnu-exam.cls`

- [ ] **Step 1: 添加页面几何和页眉代码**

```latex
% === 页面布局 ===
\RequirePackage{geometry}
\geometry{
  paper      = a4paper,
  top        = 2.54cm,
  bottom     = 2.54cm,
  left       = 3.17cm,
  right      = 3.17cm,
  headheight = 14pt,
  headsep    = 10pt,
  footskip   = 20pt,
}

% === 页眉页脚 ===
\RequirePackage{fancyhdr}
\RequirePackage{lastpage}
\RequirePackage{zref-totpages}

\fancypagestyle{plain}{
  \fancyhf{}
  \fancyhead[C]{\zihao{5} 第~\thepage~页~/~共~\ztotpages~页}
  \renewcommand{\headrulewidth}{0.4pt}
}
\pagestyle{plain}
```

- [ ] **Step 2: 测试页面布局和页眉**

```latex
% test-layout.tex
\documentclass{shnu-exam}
\usepackage{lipsum}
\begin{document}
\lipsum[1-20]
\end{document}
```

- [ ] **Step 3: 编译验证**

Run: `xelatex -interaction=nonstopmode test-layout.tex`
Expected: A4 页面，页眉居中显示"第X页/共Y页"。

- [ ] **Step 4: Commit**

---

### Task 4: 试卷头（精确行间距）

**Files:**
- Modify: `shnu-exam.cls`

- [ ] **Step 1: 添加试卷头命令和实现**

```latex
% === 试卷信息变量 ===
\RequirePackage{xparse}

\def\shnu@examtitle{}
\def\shnu@examtype{}
\def\shnu@semester{}
\def\shnu@examdate{}
\def\shnu@examduration{}

\NewDocumentCommand{\examtitle}{m}{\def\shnu@examtitle{#1}}
\NewDocumentCommand{\examtype}{m}{\def\shnu@examtype{#1}}
\NewDocumentCommand{\semester}{m}{\def\shnu@semester{#1}}
\NewDocumentCommand{\examdate}{m}{\def\shnu@examdate{#1}}
\NewDocumentCommand{\examduration}{m}{\def\shnu@examduration{#1}}

% === 试卷头（内部命令）===
\newcommand{\shnu@makeheader}{%
  \begingroup
  % P0: 标题 — 黑体 22pt 加粗，居中，单倍行距
  {\heiti\fontsize{22pt}{22pt}\selectfont\bfseries
   \centerline{上海师范大学标准试卷}\par}
  \vskip 0pt
  % P1: 学年学期 — 宋体 10.5pt，18pt 固定行距
  {\songti\fontsize{10.5pt}{18pt}\selectfont
   \centerline{\shnu@semester\hskip 2em 考试日期\hskip 2em \shnu@examdate}\par}
  % P2: 考试时间 — 宋体 10.5pt，18pt 固定行距，段后 7.8pt
  {\songti\fontsize{10.5pt}{18pt}\selectfont
   \centerline{（考试时间：\shnu@examduration~分钟）}\par}
  \vskip 7.8pt
  % P3: 科目 — 宋体 15pt 加粗，18pt 固定行距
  {\songti\bfseries\fontsize{15pt}{18pt}\selectfont
   \centerline{科目：\shnu@examtitle（\shnu@examtype）}\par}
  % P4: 学生信息 — 宋体 10.5pt，20pt 固定行距，段前 7.8pt，段后 7.8pt
  \vskip 7.8pt
  {\songti\fontsize{10.5pt}{20pt}\selectfont
   \hspace*{10.5pt}专业\hskip 2em 本科\hskip 3em 级\hskip 3em 班%
   \hskip 2em 姓名\hskip 8em 学号\par}
  \vskip 7.8pt
  \endgroup
}
```

**注意：** `\hskip` 的实际距离需要在对照原始 PDF 后微调。初期使用近似值。

- [ ] **Step 2: 编写诚信承诺和得分表占位**

```latex
% === 诚信承诺行 ===
\newcommand{\shnu@pledge}{%
  \vskip 23.4pt
  {\heiti\fontsize{12pt}{12pt}\selectfont
   \centerline{我承诺，遵守《上海师范大学考场规则》，诚信考试。%
   \hskip 2em 签名：\rule{8em}{0.4pt}}\par}
  \vskip 15.6pt
}

% === 得分表（先用固定格式占位）===
\newcommand{\shnu@scoretable}{%
  % 在 Task 5 中实现动态生成
  \vskip 7.8pt
  {\songti\fontsize{10.5pt}{10.5pt}\selectfont
   \begin{tabularx}{\textwidth}{|c|*{6}{X|}|c|}
     \hline
     题号 & 一 & 二 & 三 & 四 & 五 & 六 & 总分 \\
     \hline
     得分 &   &   &   &   &   &   &      \\
     \hline
   \end{tabularx}}\par
  \vskip 7.8pt
}
```

- [ ] **Step 3: 编写 `\maketitle` 的重定义**

```latex
\renewcommand{\maketitle}{%
  \shnu@makeheader
  \ifshnu@showscore
    \shnu@scoretable
  \fi
  \shnu@pledge
}
```

- [ ] **Step 4: 编写测试文件验证间距**

```latex
% test-header.tex
\documentclass{shnu-exam}
\examtitle{概率论与数理统计}
\examtype{A卷}
\semester{2025~2026 学年~~第~1~学期}
\examdate{2026年1月13日}
\examduration{90}
\begin{document}
\maketitle
正文从这里开始...
\end{document}
```

- [ ] **Step 5: 编译并与原 PDF 对比**

Run: `xelatex -interaction=nonstopmode test-header.tex`
Expected: 试卷头字体、字号、间距与原 PDF 一致。必要时微调 `\hskip` 值和 `\vskip` 值。

- [ ] **Step 6: Commit**

---

### Task 5: 动态得分表生成

**Files:**
- Modify: `shnu-exam.cls`

- [ ] **Step 1: 添加章节计数器和得分表生成逻辑**

```latex
% === 大题计数器（用于生成得分表）===
\newcounter{shnu@section@count}
\setcounter{shnu@section@count}{0}

% 存储大题标题
\newcommand{\shnu@section@titles}{}

% === 重定义 \section 以自动计数 ===
% 保存原始 \section
\let\shnu@orig@section\section

\RenewDocumentCommand{\section}{s m}{%
  \stepcounter{shnu@section@count}%
  % 将标题添加到列表（用于得分表）
  \ifx\shnu@section@titles\empty
    \xdef\shnu@section@titles{#2}%
  \else
    \xdef\shnu@section@titles{\shnu@section@titles,#2}%
  \fi
  % 调用原始 section 进行排版
  \IfBooleanTF{#1}
    {\shnu@orig@section*{#2}}
    {\shnu@orig@section{#2}}%
}

% === 动态生成得分表 ===
\newcommand{\shnu@scoretable}{%
  \vskip 7.8pt
  {\songti\fontsize{10.5pt}{10.5pt}\selectfont
   % 构建表格前导
   \def\table@cols{|c}
   \def\table@header{题号}
   \def\table@score{得分}
   % 遍历节标题构建列
   \@for\@secname:=\shnu@section@titles\do{%
     % 提取题号字符（一、二、三...）
     \xdef\table@cols{\table@cols|c|}
     \xdef\table@header{\table@header & \@secname}%
     \xdef\table@score{\table@score & }%
   }%
   \xdef\table@cols{\table@cols|c|}
   \xdef\table@header{\table@header & 总分}%
   \xdef\table@score{\table@score & }%
   % 渲染表格
   \begin{tabularx}{\textwidth}{\table@cols}
     \hline
     \table@header \\
     \hline
     \table@score \\
     \hline
   \end{tabularx}}\par
  \vskip 7.8pt
}
```

**注意：** 得分表中的标题需要从完整标题中提取题号部分（如从"一、选择题（每小题2分，共16分）"中提取"一"）。或者最简单的方式是要求用户在 `\section{}` 中使用简短标题。另一种方式是解析中文数字。这一步可能需要简化——直接用整个 section 标题作为列标题但截断过长内容。

**简化方案：** 得分表不自动提取标题，而是使用计数器 `\theshnu@section@count` 对应的中文数字（一、二、三...）。使用 `zhnumber` 包或自定义映射。

```latex
\RequirePackage{zhnumber}

\newcommand{\shnu@scoretable}{%
  \vskip 7.8pt
  {\songti\fontsize{10.5pt}{10.5pt}\selectfont
   \def\table@cols{|c}
   \def\table@header{题号}
   \def\table@score{得分}
   % 用中文数字生成表头
   \foreach \n in {1,...,\value{shnu@section@count}}{
     \xdef\table@cols{\table@cols|c|}
     \xdef\table@header{\table@header & \zhnumber{\n}}
   }
   \xdef\table@cols{\table@cols|c|}
   \xdef\table@header{\table@header & 总分}
   \xdef\table@score{\table@score & }
   \foreach \n in {1,...,\value{shnu@section@count}}{
     \xdef\table@score{\table@score & }
   }
   \begin{tabularx}{\textwidth}{\table@cols}
     \hline
     \table@header \\
     \hline
     \table@score \\
     \hline
   \end{tabularx}}\par
  \vskip 7.8pt
}
```

- [ ] **Step 2: 测试多节得分表**

```latex
% test-scoretable.tex
\documentclass{shnu-exam}
\examtitle{概率论与数理统计}
\examtype{A卷}
\semester{2025~2026 学年~~第~1~学期}
\examdate{2026年1月13日}
\examduration{90}
\begin{document}
\maketitle
\section{选择题（每小题2分，共16分）}
内容...
\section{填空题（每空3分，共24分）}
内容...
\section{计算题（本题10分）}
内容...
\section{计算题（本题16分）}
内容...
\section{计算题（本题16分）}
内容...
\section{计算题（本题18分）}
内容...
\end{document}
```

- [ ] **Step 3: 编译验证**

Run: `xelatex -interaction=nonstopmode test-scoretable.tex`
Expected: 得分表显示 6 列（一~六）+ 总分，格式与原试卷一致。

- [ ] **Step 4: Commit**

---

### Task 6: 大题标题和题目编号格式

**Files:**
- Modify: `shnu-exam.cls`

- [ ] **Step 1: 配置 section 格式和题目编号**

```latex
% === 行距 ===
\RequirePackage{setspace}

% === section 格式：宋体 15pt 加粗，左对齐 ===
\ctexset{
  section = {
    format     = {\heiti\bfseries\fontsize{15pt}{18pt}\selectfont\raggedright},
    beforeskip = {12pt},
    afterskip  = {8pt},
    numbering  = false,
  },
}

% === 题目编号计数器 ===
\newcounter{shnu@question}
\setcounter{shnu@question}{0}

% 每个 section 开始时重置
\BeforeBeginEnvironment{section}{\setcounter{shnu@question}{0}}

% \question 命令：自动编号
\NewDocumentCommand{\question}{o}{%
  \stepcounter{shnu@question}%
  \par
  \noindent
  {\songti\fontsize{10.5pt}{15.75pt}\selectfont
   \theshnu@question.}%
  \hspace{0.5em}%
  \IfValueT{#1}{(#1)}%
}

% === 正文字体和行距 ===
% 行距 1.5 倍（对应 Word 1.5 倍行距）
% 基准字号 10.5pt，单倍行距约 12.6pt，1.5倍≈18.9pt baseline
% 使用 setspace：\onehalfspacing 对 10.5pt 产生约 15.75pt baseline
% 如需精确匹配 Word 1.5 倍行距（~240% in Word terms），
% 使用 \setstretch{1.45} 或实测调整
\AtBeginDocument{
  \setstretch{1.45}  % 近似 Word 1.5 倍行距，可能需要微调
  \zihao{5}          % 五号 = 10.5pt
}
```

- [ ] **Step 2: 测试题目编号和行距**

```latex
% test-question.tex
\documentclass{shnu-exam}
\examtitle{概率论与数理统计}
\examtype{A卷}
\semester{2025~2026 学年~~第~1~学期}
\examdate{2026年1月13日}
\examduration{90}
\begin{document}
\maketitle

\section{一、选择题（每小题2分，共16分）}

\question 以下说法中正确的是

\question 设随机变量 $X$ 服从参数为$\lambda$（$\lambda>0$）的泊松分布，且$P(X=1)=P(X=2)$，则$\lambda$的值为

\section{二、填空题（每空3分，共24分）}

\question 已知$P(A)=0.6$，$P(B)=0.5$，$P(AB)=0.2$，则$P(A\bar{B})=$ \fillin

\end{document}
```

- [ ] **Step 3: 编译验证**

Run: `xelatex -interaction=nonstopmode test-question.tex`
Expected: 题目自动编号，行距 1.5 倍，section 标题宋体加粗 15pt。

- [ ] **Step 4: Commit**

---

### Task 7: 选择题选项自动排版

**Files:**
- Modify: `shnu-exam.cls`

- [ ] **Step 1: 实现选项测量和布局引擎**

```latex
% === 选择题选项 ===
% 计数器：追踪当前组内第几个选项
\newcounter{shnu@choice@cnt}
\setcounter{shnu@choice@cnt}{0}

% 存储四个选项内容的盒子
\newsavebox{\shnu@choice@box@A}
\newsavebox{\shnu@choice@box@B}
\newsavebox{\shnu@choice@box@C}
\newsavebox{\shnu@choice@box@D}

% 选项标签
\def\shnu@choice@label@A{A.}
\def\shnu@choice@label@B{B.}
\def\shnu@choice@label@C{C.}
\def\shnu@choice@label@D{D.}

\NewDocumentCommand{\choice}{o m}{%
  \stepcounter{shnu@choice@cnt}%
  \expandafter\newsavebox\expandafter{\csname shnu@choice@\theshnu@choice@cnt\endcsname}%
  \expandafter\sbox\expandafter{\csname shnu@choice@\theshnu@choice@cnt\endcsname}{%
    \songti\fontsize{10.5pt}{15.75pt}\selectfont
    \csname shnu@choice@label@\@Alph\theshnu@choice@cnt\endcsname~#2%
  }%
  \ifnum\value{shnu@choice@cnt}=4
    \shnu@choice@layout
    \setcounter{shnu@choice@cnt}{0}%
  \fi
}

% 布局决策
\newcommand{\shnu@choice@layout}{%
  \par
  % 获取四个选项的宽度
  \newdimen\@wA \newdimen\@wB \newdimen\@wC \newdimen\@wD
  \@wA=\wd\shnu@choice@box@A
  \@wB=\wd\shnu@choice@box@B
  \@wC=\wd\shnu@choice@box@C
  \@wD=\wd\shnu@choice@box@D
  % 获取最大宽度
  \newdimen\@maxW
  \@maxW=\@wA
  \ifdim\@wB>\@maxW \@maxW=\@wB \fi
  \ifdim\@wC>\@maxW \@maxW=\@wC \fi
  \ifdim\@wD>\@maxW \@maxW=\@wD \fi
  %
  % 判断布局模式
  % 列间距
  \newdimen\@colsep
  \@colsep=2em
  %
  \ifdim\@maxW<0.22\linewidth
    % 模式1：4列一行
    \shnu@choice@layout@four
  \else
    \ifdim\@maxW<0.45\linewidth
      % 模式2：2×2 网格
      \shnu@choice@layout@twobytwo
    \else
      % 模式3：每项一行
      \shnu@choice@layout@stacked
    \fi
  \fi
}

% 4列一行
\newcommand{\shnu@choice@layout@four}{%
  \noindent
  \usebox{\shnu@choice@box@A}\hfill
  \usebox{\shnu@choice@box@B}\hfill
  \usebox{\shnu@choice@box@C}\hfill
  \usebox{\shnu@choice@box@D}\par
}

% 2×2 网格（A和B一行，C和D一行）
\newcommand{\shnu@choice@layout@twobytwo}{%
  \noindent
  \usebox{\shnu@choice@box@A}\hfill
  \usebox{\shnu@choice@box@B}\par
  \noindent
  \usebox{\shnu@choice@box@C}\hfill
  \usebox{\shnu@choice@box@D}\par
}

% 每项一行
\newcommand{\shnu@choice@layout@stacked}{%
  \noindent\usebox{\shnu@choice@box@A}\par
  \noindent\usebox{\shnu@choice@box@B}\par
  \noindent\usebox{\shnu@choice@box@C}\par
  \noindent\usebox{\shnu@choice@box@D}\par
}
```

- [ ] **Step 2: 测试三种布局模式**

```latex
% test-choices.tex
\documentclass{shnu-exam}
\examtitle{概率论与数理统计}
\examtype{A卷}
\semester{2025~2026 学年~~第~1~学期}
\examdate{2026年1月13日}
\examduration{90}
\begin{document}
\maketitle

\section{一、选择题}

% 短选项 → 4列
\question 设随机变量 $X\sim N(1,4)$，$Y\sim N(2,9)$，则$Z=X-Y$服从的分布为
\choice{$N(-1,13)$}
\choice{$N(3,13)$}
\choice{$N(-1,5)$}
\choice{$N(3,5)$}

% 中等选项 → 2×2
\question 下列关于大数定律的表述，正确的是
\choice{切比雪夫大数定律要求随机变量序列相互独立且同分布}
\choice{辛钦大数定律可用于判断样本均值的分布类型}
\choice{伯努利大数定律验证了"频率的稳定性"，是大数定律的重要应用}
\choice{大数定律表明，样本量越大，样本均值与总体均值的偏差一定越小}

% 长选项 → 每行一个
\question 在假设检验中，若显著性水平$\alpha=0.05$，下列说法正确的是
\choice{拒绝原假设$H_0$的概率为0.05}
\choice{接受原假设$H_0$的概率为0.05}
\choice{原假设$H_0$成立时，拒绝$H_0$的概率为0.05}
\choice{备择假设$H_1$成立时，接受$H_0$的概率为0.05}
\end{document}
```

- [ ] **Step 3: 编译验证**

Run: `xelatex -interaction=nonstopmode test-choices.tex`
Expected: 三组选项分别以 4列、2×2、4行 三种模式排版。调整阈值（0.22/0.45）直至效果合理。

- [ ] **Step 4: Commit**

---

### Task 8: 填空题和解答题答题区

**Files:**
- Modify: `shnu-exam.cls`

- [ ] **Step 1: 实现填空线和答题空白区**

```latex
% === 填空题 ===
\NewDocumentCommand{\fillin}{o}{%
  \IfNoValueTF{#1}
    {\rule{3cm}{0.4pt}}                           % 无答案时画空线
    {%
      \ifshnu@solution
        \underline{\textcolor{red}{#1}}            % 显示答案
      \else
        \rule{3cm}{0.4pt}                          % 隐藏答案时画空线
      \fi
    }%
}

% === 解答题答题区 ===
% 全局默认答题行数
\def\shnu@answerspace{10}
\AtBeginDocument{%
  \edef\shnu@answerspace{\shnu@answerspace}%
}

% 每行高度（与正文行距一致）
\newdimen\shnu@answerlineheight
\shnu@answerlineheight=15.75pt  % 1.5倍行距的单行高度

\NewDocumentCommand{\problem}{o m}{%
  \par
  \noindent #2\par
  % 答题空白区
  \IfNoValueTF{#1}
    {% 使用全局默认行数
      \shnu@makeanswerspace{\shnu@answerspace}%
    }
    {% 解析可选参数
      \shnu@parseanswerspace{#1}%
    }%
}

% 生成答题空白行
\newcommand{\shnu@makeanswerspace}[1]{%
  \vspace{6pt}
  \loop
    \noindent\rule{0pt}{\shnu@answerlineheight}%
    \hrulefill\par
    \advance#1 by -1
    \ifnum#1>0
  \repeat
  \vspace{6pt}
}

% 解析 lines=N 或 space=Xcm
\newcommand{\shnu@parseanswerspace}[1]{%
  \shnu@parse@lines#1\@nil
}
\def\shnu@parse@lines lines=#1\@nil{%
  \shnu@makeanswerspace{#1}%
}
% 如果指定具体高度，使用 vspace
% 简化处理：直接支持 key=val
```

**简化方案：** 避免复杂的参数解析，让 `\problem` 的选项直接支持 `lines` 和 `space` 两种 key。

```latex
\RequirePackage{pgfkeys}

\pgfkeys{
  /shnu/.is family, /shnu,
  lines/.store in = \shnu@tmp@lines,
  space/.store in = \shnu@tmp@space,
  lines/.default = \shnu@answerspace,
  space/.default = 3cm,
}

\NewDocumentCommand{\problem}{O{} m}{%
  \par
  \noindent #2\par
  \def\shnu@tmp@lines{\shnu@answerspace}%
  \def\shnu@tmp@space{}%
  \pgfkeys{/shnu, #1}%
  \ifx\shnu@tmp@space\empty
    \shnu@makeanswerspace{\shnu@tmp@lines}%
  \else
    \vspace{\shnu@tmp@space}%
  \fi
}
```

- [ ] **Step 2: 测试答题区**

```latex
% test-answerspace.tex
\documentclass{shnu-exam}
\examtitle{概率论与数理统计}
\examtype{A卷}
\semester{2025~2026 学年~~第~1~学期}
\examdate{2026年1月13日}
\examduration{90}
\begin{document}
\maketitle

\section{三、计算题（本题10分）}

\problem[lines=15]{某实验室有三台检测设备A、B、C...}

\section{四、计算题（本题16分）}

\problem[space=8cm]{设二维随机变量$(X,Y)$的联合概率密度函数为...}

\end{document}
```

- [ ] **Step 3: 编译验证**

Run: `xelatex -interaction=nonstopmode test-answerspace.tex`
Expected: 第一题留15行空白横线，第二题留8cm空白。

- [ ] **Step 4: Commit**

---

### Task 9: 得分栏和细节调整

**Files:**
- Modify: `shnu-exam.cls`

- [ ] **Step 1: 在每个 section 标题旁添加"得分"标签**

```latex
% 重新定义 section 添加得分栏
\ctexset{
  section = {
    format     = {\heiti\bfseries\fontsize{15pt}{18pt}\selectfont\raggedright},
    beforeskip = {12pt},
    afterskip  = {8pt},
    numbering  = false,
    aftername  = {%
      \ifshnu@showscore
        \hfill {\songti\fontsize{10.5pt}{10.5pt}\selectfont 得分\rule{2cm}{0.4pt}}%
      \fi
    },
  },
}
```

- [ ] **Step 2: 调整试卷头各 `\hskip` 间距**

通过编译并与原 PDF 逐行对比，微调：
- 标题下方间距
- P1~P4 各行的水平和垂直间距
- 诚信承诺行的间距

- [ ] **Step 3: 提交完整 shnu-exam.cls**

- [ ] **Step 4: Commit**

---

### Task 10: 创建示例文件和文档

**Files:**
- Create: `example-2026-1-A.tex`
- Create: `README.html`

- [ ] **Step 1: 创建完整示例（还原原试卷）**

创建 `example-2026-1-A.tex`，将原 PDF 中的全部题目录入 LaTeX 格式。只录入一页以验证格式，完整重现试卷头、得分表、选择题、填空题、解答题。

- [ ] **Step 2: 编译并与原 PDF 视觉对比**

Run: `xelatex -interaction=nonstopmode example-2026-1-A.tex`
Expected: 格式与原 PDF 高度一致。逐项检查：字体、大小、行间距、边距、得分表位置。

- [ ] **Step 3: 编写 README.html 使用文档**

中文 HTML 格式，包含：
- 快速入门示例
- 完整命令参考
- 选项说明
- 编译要求

- [ ] **Step 4: 最终 commit**

---

### 验证标准

| 检查项 | 标准 |
|--------|------|
| 字体 | 标题黑体加粗22pt，科目宋体加粗15pt，正文宋体10.5pt，西文Times New Roman |
| 行间距 | 试卷头：18pt/20pt 固定值匹配；正文：1.5倍行距 |
| 页边距 | 上下2.54cm，左右3.17cm |
| 页眉 | "第X页/共Y页" 居中 |
| 得分表 | 根据section数量自动生成，中文数字列标题 |
| 选项排版 | 三种模式自动切换（4列/2×2/4行） |
| 答题区 | lines=N 和 space=Xcm 均可用 |
| 编译 | XeLaTeX × 1 次即可，无错误（选项布局不需要 aux 辅助） |
