% shnu-exam.cls — 上海师范大学考试卷文档类
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{shnu-exam}[2026/05/17 v1.0 SHNU Exam Class]

% ===== 类选项 =====
\RequirePackage{kvoptions}
\SetupKeyvalOptions{family=shnu, prefix=shnu@}

\DeclareStringOption[10]{answerspace}
\DeclareBoolOption[true]{showscore}
\DeclareBoolOption[false]{solution}

\DeclareDefaultOption{\PassOptionsToClass{\CurrentOption}{ctexart}}
\ProcessKeyvalOptions{shnu}

% ===== 基础文档类 =====
\LoadClass[a4paper]{ctexart}

% ===== 必需宏包 =====
\RequirePackage{fontspec}
\RequirePackage{unicode-math}
\RequirePackage{xparse}
\RequirePackage{geometry}
\RequirePackage{fancyhdr}
\RequirePackage{lastpage}
\RequirePackage{zref-totpages}
\RequirePackage{tabularx}
\RequirePackage{enumitem}
\RequirePackage{setspace}
\RequirePackage{calc}
\RequirePackage{environ}
\RequirePackage{etoolbox}
\RequirePackage{zhnumber}
\RequirePackage{pgfkeys}

% ===== 字体配置 =====
% 中文主字体：宋体 (ctex 已自动映射 \songti)
\setCJKmainfont{SimSun}[
  BoldFont = SimHei,
]

% 中文无衬线：黑体 (ctex 已自动映射 \heiti)
\setCJKsansfont{SimHei}[
  BoldFont = SimHei,
]

% 中文等宽
\setCJKmonofont{FangSong}

% 额外的中文字体族（\fangsong, \kaishu 由 ctex 自动映射）
\setCJKfamilyfont{zhfs}{FangSong}
\setCJKfamilyfont{zhkai}{KaiTi}

% 西文主字体：Times New Roman
\setmainfont{Times New Roman}[
  BoldFont       = Times New Roman Bold,
  ItalicFont     = Times New Roman Italic,
  BoldItalicFont = Times New Roman Bold Italic,
]

% 西文无衬线
\setsansfont{Arial}

% 数学字体：Times 风格
\setmathfont{TeX Gyre Termes Math}

% ===== 页面布局 =====
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

% ===== 页眉页脚 =====
\fancypagestyle{plain}{
  \fancyhf{}
  \fancyhead[C]{\zihao{5} 第~\thepage~页~/~共~\ztotpages~页}
  \renewcommand{\headrulewidth}{0.4pt}
}
\pagestyle{plain}

% ===== 试卷信息变量 =====
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

% ===== 试卷头（精确匹配原文档行间距）=====
\newcommand{\shnu@makeheader}{%
  \begingroup
  % P0: 标题 — 黑体 22pt，居中（黑体本身即为粗体）
  {\heiti\fontsize{22pt}{22pt}\selectfont
   \centerline{上海师范大学标准试卷}\par}
  % P1: 学年学期 — 10.5pt，行距 18pt 固定值
  {\songti\fontsize{10.5pt}{18pt}\selectfont
   \centerline{\shnu@semester\hskip 2em 考试日期\hskip 2em \shnu@examdate}\par}
  % P2: 考试时间 — 10.5pt，行距 18pt，段后 7.8pt
  {\songti\fontsize{10.5pt}{18pt}\selectfont
   \centerline{（考试时间：\shnu@examduration~分钟）}\par}
  \vskip 7.8pt
  % P3: 科目 — 黑体 15pt（宋体加粗 = 黑体），行距 18pt
  {\heiti\fontsize{15pt}{18pt}\selectfont
   \centerline{科目：\shnu@examtitle（\shnu@examtype）}\par}
  % P4: 学生信息 — 10.5pt，行距 20pt，段前 7.8pt，段后 7.8pt，首行缩进 10.5pt
  \vskip 7.8pt
  {\songti\fontsize{10.5pt}{20pt}\selectfont
   \hspace*{10.5pt}专业\hskip 2em 本科\hskip 3em 级\hskip 3em 班%
   \hskip 2em 姓名\hskip 8em 学号\par}
  \vskip 7.8pt
  \endgroup
}

% ===== 诚信承诺行 =====
\newcommand{\shnu@pledge}{%
  \vskip 23.4pt
  {\heiti\fontsize{12pt}{12pt}\selectfont
   \centerline{我承诺，遵守《上海师范大学考场规则》，诚信考试。%
   \hskip 2em 签名：\rule{8em}{0.4pt}}\par}
  \vskip 15.6pt
}

% ===== 大题计数器（使用 .aux 文件实现延迟收集）=====
\newcounter{shnu@section@cnt}

% 从 .aux 文件收集的 section 序号列表
\newcommand{\shnu@section@list}{}

% 得分表的列定义、表头、得分行（在 \AtBeginDocument 中预构建）
% 默认值：只有 题号 和 总分 两列（首个编译周期）
\def\shnu@score@cols{|c|c|}
\def\shnu@score@header{题号 & 总分}
\def\shnu@score@row{得分 & }

% 中文数字映射（完全可展开）
\def\shnu@cnum#1{%
  \ifcase#1\or 一\or 二\or 三\or 四\or 五\or 六\or 七\or 八\or 九\or 十\fi
}

% 辅助宏：向得分表添加一列（#1 为已展开的序号）
\def\shnu@addcol#1{%
  \expandafter\gdef\expandafter\@tmpcols\expandafter{\@tmpcols c|}%
  \expandafter\gdef\expandafter\@tmpheader\expandafter{\@tmpheader & \shnu@cnum{#1}}%
  \expandafter\gdef\expandafter\@tmprow\expandafter{\@tmprow & }%
}

% 从 .aux 读取时调用：添加到列表
\newcommand{\shnu@gather@section}[1]{%
  \ifx\shnu@section@list\empty
    \xdef\shnu@section@list{#1}%
  \else
    \xdef\shnu@section@list{\shnu@section@list,#1}%
  \fi
}

% 保存原始 \section，重定义以自动计数 + 写入 .aux
\let\shnu@orig@section\section
\RenewDocumentCommand{\section}{s m}{%
  \stepcounter{shnu@section@cnt}%
  \immediate\write\@auxout{%
    \string\shnu@gather@section{\theshnu@section@cnt}%
  }%
  \IfBooleanTF{#1}
    {\shnu@orig@section*{#2}}
    {\shnu@orig@section{#2}}%
}

% 在 \AtBeginDocument 中根据 .aux 数据预构建得分表内容
\AtBeginDocument{%
  \ifx\shnu@section@list\empty\else
    % 为每个 section 在"总分"前插入列
    % 重建列定义：在最后的 |c| 前插入 N 个 c|
    \def\@tmpcols{|c}
    \def\@tmpheader{题号}
    \def\@tmprow{得分}
    \@for\@n:=\shnu@section@list\do{%
      \expandafter\shnu@addcol\expandafter{\@n}%
    }%
    % 追加"总分"列
    \expandafter\gdef\expandafter\@tmpcols\expandafter{\@tmpcols c|}%
    \expandafter\gdef\expandafter\@tmpheader\expandafter{\@tmpheader & 总分}%
    \expandafter\gdef\expandafter\@tmprow\expandafter{\@tmprow & }%
    % 赋值到正式宏
    \global\let\shnu@score@cols\@tmpcols
    \global\let\shnu@score@header\@tmpheader
    \global\let\shnu@score@row\@tmprow
  \fi
}

% ===== 动态得分表 =====
\newcommand{\shnu@scoretable}{%
  \vskip 7.8pt
  {\songti\fontsize{10.5pt}{10.5pt}\selectfont
   \centering
   % 将整个 tabular 预展开到 \@tempa 后执行
   \protected@xdef\@tempa{%
     \noexpand\begin{tabular}{\shnu@score@cols}%
       \noexpand\hline
       \shnu@score@header
       \noexpand\\
       \noexpand\hline
       \shnu@score@row
       \noexpand\\
       \noexpand\hline
     \noexpand\end{tabular}%
   }%
   \@tempa\par}
  \vskip 7.8pt
}

% ===== 重定义 \maketitle =====
\renewcommand{\maketitle}{%
  \shnu@makeheader
  \ifshnu@showscore
    \shnu@scoretable
  \fi
  \shnu@pledge
}

% ===== section 格式 =====
\ctexset{
  section = {
    format     = {\heiti\fontsize{15pt}{18pt}\selectfont\raggedright},
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

% ===== 题目编号 =====
\newcounter{shnu@question}
\setcounter{shnu@question}{0}

% 每个 section 开始时重置题目编号
\BeforeBeginEnvironment{section}{\setcounter{shnu@question}{0}}

\NewDocumentCommand{\question}{}{%
  \stepcounter{shnu@question}%
  \par
  \noindent
  {\songti\fontsize{10.5pt}{15.75pt}\selectfont
   \theshnu@question.}%
  \hspace{0.5em}%
}

% ===== 正文字体和行距 =====
\AtBeginDocument{%
  \setstretch{1.45}%  近似 Word 1.5 倍行距
  \zihao{5}%          五号 = 10.5pt
}

% ===== 选择题选项 =====
\newcounter{shnu@choice@cnt}
\setcounter{shnu@choice@cnt}{0}

% 四个选项的盒子
\newsavebox{\shnu@choice@box@A}
\newsavebox{\shnu@choice@box@B}
\newsavebox{\shnu@choice@box@C}
\newsavebox{\shnu@choice@box@D}

\def\shnu@choice@label@A{A.}
\def\shnu@choice@label@B{B.}
\def\shnu@choice@label@C{C.}
\def\shnu@choice@label@D{D.}

\NewDocumentCommand{\choice}{m}{%
  \stepcounter{shnu@choice@cnt}%
  % 将内容存入对应盒子
  \ifcase\value{shnu@choice@cnt}\or
    \global\setbox\shnu@choice@box@A=\hbox{%
      {\songti\fontsize{10.5pt}{15.75pt}\selectfont\shnu@choice@label@A~#1}%
    }%
  \or
    \global\setbox\shnu@choice@box@B=\hbox{%
      {\songti\fontsize{10.5pt}{15.75pt}\selectfont\shnu@choice@label@B~#1}%
    }%
  \or
    \global\setbox\shnu@choice@box@C=\hbox{%
      {\songti\fontsize{10.5pt}{15.75pt}\selectfont\shnu@choice@label@C~#1}%
    }%
  \or
    \global\setbox\shnu@choice@box@D=\hbox{%
      {\songti\fontsize{10.5pt}{15.75pt}\selectfont\shnu@choice@label@D~#1}%
    }%
    % 第四个选项到达，执行布局
    \shnu@choice@layout
    \setcounter{shnu@choice@cnt}{0}%
  \fi
}

% 布局决策：测量四个选项宽度，选择最优排版
\newcommand{\shnu@choice@layout}{%
  \par
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
  \ifdim\@maxW<0.22\linewidth
    \shnu@choice@fourinarow
  \else
    \ifdim\@maxW<0.45\linewidth
      \shnu@choice@twobytwo
    \else
      \shnu@choice@stacked
    \fi
  \fi
}

% 模式1：4列一行
\newcommand{\shnu@choice@fourinarow}{%
  \noindent
  \copy\shnu@choice@box@A\hfill
  \copy\shnu@choice@box@B\hfill
  \copy\shnu@choice@box@C\hfill
  \copy\shnu@choice@box@D\par
}

% 模式2：2×2 网格
\newcommand{\shnu@choice@twobytwo}{%
  \noindent
  \copy\shnu@choice@box@A\hfill
  \copy\shnu@choice@box@B\par
  \noindent
  \copy\shnu@choice@box@C\hfill
  \copy\shnu@choice@box@D\par
}

% 模式3：4行堆叠
\newcommand{\shnu@choice@stacked}{%
  \noindent\copy\shnu@choice@box@A\par
  \noindent\copy\shnu@choice@box@B\par
  \noindent\copy\shnu@choice@box@C\par
  \noindent\copy\shnu@choice@box@D\par
}

% ===== 填空题 =====
\NewDocumentCommand{\fillin}{o}{%
  \IfNoValueTF{#1}
    {\rule{3cm}{0.4pt}}
    {%
      \ifshnu@solution
        \underline{\textcolor{red}{#1}}%
      \else
        \rule{3cm}{0.4pt}%
      \fi
    }%
}

% ===== 解答题答题区 =====
\def\shnu@answerspace{10}
\AtBeginDocument{%
  \edef\shnu@answerspace{\shnu@answerspace}%
}

\newdimen\shnu@answerlineheight
\shnu@answerlineheight=15.75pt

% 生成答题空白行
\newcommand{\shnu@makeanswerspace}[1]{%
  \vspace{6pt}%
  \newcount\@linecnt
  \@linecnt=#1\relax
  \loop
    \noindent\rule{0pt}{\shnu@answerlineheight}%
    \leavevmode\rlap{\hrulefill}\par
    \advance\@linecnt by -1
    \ifnum\@linecnt>0
  \repeat
  \vspace{6pt}%
}

% 解析 key=val 可选参数
\pgfkeys{
  /shnu/.is family, /shnu,
  lines/.store in = \shnu@tmp@lines,
  space/.store in = \shnu@tmp@space,
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

\endinput
