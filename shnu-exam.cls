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
\RequirePackage{xparse}
\RequirePackage{geometry}
\RequirePackage{fancyhdr}
\RequirePackage{lastpage}
\RequirePackage{zref-totpages}
\RequirePackage{tabularx}
\RequirePackage{enumitem}
\RequirePackage{setspace}
\RequirePackage{calc}
\RequirePackage{etoolbox}
\RequirePackage{zhnumber}
\RequirePackage{pgfkeys}
\RequirePackage{amsmath}
\RequirePackage{newtxmath}
\RequirePackage{xcolor}
\RequirePackage{xstring}

% ===== 字体配置 =====
% 宋体（常规）
\setCJKmainfont{SimSun}
% 宋体加粗 — 使用 FakeBold，与黑体视觉不同
\setCJKfamilyfont{zhsongBold}{SimSun}[FakeBold=3.5]
% 黑体（常规）
\setCJKsansfont{SimHei}
% 黑体加粗 — 在 SimHei 基础上再加重，与常规黑体不同
\setCJKfamilyfont{zhheiBold}{SimHei}[FakeBold=3.5]

\NewDocumentCommand{\songtiBold}{}{\CJKfamily{zhsongBold}}
\NewDocumentCommand{\heitiBold}{}{\CJKfamily{zhheiBold}}

% ctex 自动映射的 \songti / \heiti 使用常规字重
% 额外中文字体族
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

% 数学字体：newtxmath（Times 风格，与西文正文 Times New Roman 匹配）

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

% ===== 页脚（页数放在页脚，无横线）=====
\fancypagestyle{plain}{
  \fancyhf{}
  \fancyfoot[C]{\zihao{5} 第\thepage 页/共\ztotpages 页}
  \renewcommand{\headrulewidth}{0pt}
  \renewcommand{\footrulewidth}{0pt}
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

% ===== 试卷头 =====
\newcommand{\shnu@makeheader}{%
  \begingroup
  % P0: 标题 — 黑体加粗 22pt，居中
  {\heitiBold\fontsize{22pt}{22pt}\selectfont
   \centerline{上海师范大学标准试卷}\par}
  % P1: 学年学期 — 宋体 10.5pt，行距 15pt
  {\songti\fontsize{10.5pt}{15pt}\selectfont
   \centerline{\shnu@semester\hskip 1em 考试日期\hskip 1em \shnu@examdate}\par}
  % P2: 考试时间 — 宋体 10.5pt，行距 15pt，段后 4pt
  {\songti\fontsize{10.5pt}{15pt}\selectfont
   \centerline{（考试时间：\shnu@examduration~分钟）}\par}
  \vskip 4pt
  % P3: 科目 — 宋体加粗 15pt，行距 16pt
  {\songtiBold\fontsize{15pt}{16pt}\selectfont
   \centerline{科目：\shnu@examtitle（\shnu@examtype）}\par}
  % P4: 学生信息 — 宋体 10.5pt，行距 16pt，段前 4pt，段后 4pt
  % 用 \rule 替代 \underline 消除字符与下划线间的间隙
  \vskip 4pt
  {\songti\fontsize{10.5pt}{16pt}\selectfont
   \noindent
   \rule[-2pt]{8em}{0.4pt}专业%
   \hskip 0.5em 本科\rule[-2pt]{3.5em}{0.4pt}%
   \hskip 0.5em 级\rule[-2pt]{2.5em}{0.4pt}%
   \hskip 0.5em 班\hfill
   姓名\rule[-2pt]{4.5em}{0.4pt}%
   \hskip 0.3em 学号\rule[-2pt]{8em}{0.4pt}\par}
  \vskip 4pt
  \endgroup
}

% ===== 诚信承诺行 =====
\newcommand{\shnu@pledge}{%
  \vskip 14pt
  {\heiti\fontsize{12pt}{12pt}\selectfont
   \centerline{我承诺，遵守《上海师范大学考场规则》，诚信考试。%
   \hskip 1em 签名：\rule{6em}{0.4pt}}\par}
  \vskip 10pt
}

% ===== 大题计数器（使用 .aux 文件）=====
\newcounter{shnu@section@cnt}
\newcommand{\shnu@section@list}{}

% 中文数字映射
\def\shnu@cnum#1{%
  \ifcase#1\or 一\or 二\or 三\or 四\or 五\or 六\or 七\or 八\or 九\or 十\fi
}

% 辅助宏：向得分表添加一列（#1 为中文字号）
\def\shnu@addcol#1{%
  \expandafter\gdef\expandafter\@tmpcols\expandafter{\@tmpcols | >{\centering\arraybackslash}X}%
  \expandafter\gdef\expandafter\@tmpheader\expandafter{\@tmpheader & \shnu@cnum{#1}}%
  \expandafter\gdef\expandafter\@tmprow\expandafter{\@tmprow & }%
}

% 从 .aux 读取
\newcommand{\shnu@gather@section}[1]{%
  \ifx\shnu@section@list\empty
    \xdef\shnu@section@list{#1}%
  \else
    \xdef\shnu@section@list{\shnu@section@list,#1}%
  \fi
}

% 得分表默认值（X 列自适应 + 居中 + 竖线）
\def\shnu@score@cols{|>{\centering\arraybackslash}X|>{\centering\arraybackslash}X|}
\def\shnu@score@header{题号 & 总分}
\def\shnu@score@row{得分 & }

% 重定义 \section：自动计数 + 写入 .aux + 题号重置
% 可选参数：\section[newpage]{标题} 从新页开始
% 得分框：两列等宽表格；题头小四宋体加粗同行显示
\let\shnu@orig@section\section
\RenewDocumentCommand{\section}{s o m}{%
  \everypar{}%     清除悬挂缩进
  \parindent=0pt%  重置段首缩进
  \IfValueT{#2}{\newpage}%
  \setcounter{shnu@question}{0}%
  \stepcounter{shnu@section@cnt}%
  \immediate\write\@auxout{%
    \string\shnu@gather@section{\theshnu@section@cnt}%
  }%
  \par\vspace{12pt}
  \noindent
  \ifshnu@showscore
    \begin{tabular}{|p{0.75cm}|p{0.75cm}|}
      \hline
      \centering 得分 & \\[4pt]
      \hline
    \end{tabular}%
    \hspace{1em}%
  \fi
  {\songtiBold\fontsize{12pt}{16pt}\selectfont\raggedright #3}%
  \par\vspace{8pt}
}

% 移除 ctex 默认 section 格式（由上面手动控制）
\ctexset{
  section = {
    format     = {},
    beforeskip = {0pt},
    afterskip  = {0pt},
    numbering  = false,
  },
}

% 在 \AtBeginDocument 中根据 .aux 预构建得分表
\AtBeginDocument{%
  \ifx\shnu@section@list\empty\else
    \def\@tmpcols{|>{\centering\arraybackslash}X}
    \def\@tmpheader{题号}
    \def\@tmprow{得分}
    \@for\@n:=\shnu@section@list\do{%
      \expandafter\shnu@addcol\expandafter{\@n}%
    }%
    \expandafter\gdef\expandafter\@tmpcols\expandafter{\@tmpcols | >{\centering\arraybackslash}X|}%
    \expandafter\gdef\expandafter\@tmpheader\expandafter{\@tmpheader & 总分}%
    \expandafter\gdef\expandafter\@tmprow\expandafter{\@tmprow & }%
    \global\let\shnu@score@cols\@tmpcols
    \global\let\shnu@score@header\@tmpheader
    \global\let\shnu@score@row\@tmprow
  \fi
}

% ===== 得分表（tabularx 自适应宽度）=====
\newcommand{\shnu@scoretable}{%
  \vskip 6pt
  {\songti\fontsize{10.5pt}{10.5pt}\selectfont
   \centering
   \protected@xdef\@tempa{%
     \noexpand\begin{tabularx}{\textwidth}{\shnu@score@cols}%
       \noexpand\hline
       \shnu@score@header
       \noexpand\\
       \noexpand\hline
       \shnu@score@row
       \noexpand\\
       \noexpand\hline
     \noexpand\end{tabularx}%
   }%
   \@tempa\par}
  \vskip 6pt
}

% ===== 重定义 \maketitle =====
\renewcommand{\maketitle}{%
  \shnu@makeheader
  \ifshnu@showscore
    \shnu@scoretable
  \fi
  \shnu@pledge
}

% ===== 题目编号（悬挂缩进）=====
\newcounter{shnu@question}
\setcounter{shnu@question}{0}

% 题号盒子宽度
\newdimen\shnu@question@indent
\shnu@question@indent=2.5em

\NewDocumentCommand{\question}{}{%
  \stepcounter{shnu@question}%
  \par\vspace{4pt}%
  \everypar{\hangindent=\shnu@question@indent\hangafter=1}%
  \parindent=\shnu@question@indent
  \noindent
  \makebox[\shnu@question@indent][l]{{\songti\fontsize{10.5pt}{15.75pt}\selectfont\theshnu@question.}\hspace{0.5em}}%
}

% ===== 正文行距 =====
\AtBeginDocument{%
  \setstretch{1.55}%
  \zihao{5}%
  \relpenalty=10000    % 禁止行内公式在关系符处换行
  \binoppenalty=10000  % 禁止行内公式在二元运算符处换行
}

% ===== 选择题选项 =====
\newcounter{shnu@choice@cnt}
\setcounter{shnu@choice@cnt}{0}

\newsavebox{\shnu@choice@box@A}
\newsavebox{\shnu@choice@box@B}
\newsavebox{\shnu@choice@box@C}
\newsavebox{\shnu@choice@box@D}

\def\shnu@choice@label@A{A.}
\def\shnu@choice@label@B{B.}
\def\shnu@choice@label@C{C.}
\def\shnu@choice@label@D{D.}

% 选项左缩进（与题目文字对齐）
\newdimen\shnu@choice@indent
\shnu@choice@indent=2.5em

\NewDocumentCommand{\choice}{m}{%
  \stepcounter{shnu@choice@cnt}%
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
    \shnu@choice@layout
    \setcounter{shnu@choice@cnt}{0}%
  \fi
}

% 布局决策
\newcommand{\shnu@choice@layout}{%
  \par
  \newdimen\@wA \newdimen\@wB \newdimen\@wC \newdimen\@wD
  \@wA=\wd\shnu@choice@box@A
  \@wB=\wd\shnu@choice@box@B
  \@wC=\wd\shnu@choice@box@C
  \@wD=\wd\shnu@choice@box@D
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

% 4列一行（左缩进对齐）
\newcommand{\shnu@choice@fourinarow}{%
  \noindent\hspace{\shnu@choice@indent}%
  \copy\shnu@choice@box@A\hfill
  \copy\shnu@choice@box@B\hfill
  \copy\shnu@choice@box@C\hfill
  \copy\shnu@choice@box@D\par
}

% 2×2 网格 — B/D 从行中间开始
\newcommand{\shnu@choice@twobytwo}{%
  \noindent\hspace{\shnu@choice@indent}%
  \begin{tabular}{@{}p{0.45\linewidth}@{}p{0.45\linewidth}@{}}
    \copy\shnu@choice@box@A & \copy\shnu@choice@box@B \\
    \copy\shnu@choice@box@C & \copy\shnu@choice@box@D \\
  \end{tabular}\par
}

% 4行堆叠
\newcommand{\shnu@choice@stacked}{%
  \noindent\hspace{\shnu@choice@indent}\copy\shnu@choice@box@A\par
  \noindent\hspace{\shnu@choice@indent}\copy\shnu@choice@box@B\par
  \noindent\hspace{\shnu@choice@indent}\copy\shnu@choice@box@C\par
  \noindent\hspace{\shnu@choice@indent}\copy\shnu@choice@box@D\par
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

\pgfkeys{
  /shnu/.is family, /shnu,
  lines/.store in = \shnu@tmp@lines,
  space/.store in = \shnu@tmp@space,
}

\NewDocumentCommand{\problem}{O{} +m}{%
  \par
  \everypar{}% 清除 \question 设置的悬挂缩进
  \begingroup
  \parindent=0pt
  \noindent #2\par
  \endgroup
  \def\shnu@tmp@lines{\shnu@answerspace}%
  \def\shnu@tmp@space{}%
  \pgfkeys{/shnu, #1}%
  \ifx\shnu@tmp@space\empty
    \shnu@makeanswerspace{\shnu@tmp@lines}%
  \else
    \vspace{\shnu@tmp@space}%
  \fi
}

% ===== 答案显示 =====
% \answer[choice]{A}   → solution=false: (    )  /  solution=true: (A)
% \answer[blank]{文本}  → solution=false: 加宽下划线 /  solution=true: 填答案的下划线
% \answer{文本}         → solution=false: 无显示  /  solution=true: 显示答案段落
\NewDocumentCommand{\answer}{o +m}{%
  \ifshnu@solution
    \IfNoValueTF{#1}
      {\par\noindent{\heiti 答案：}#2\par}%      无参：段落答案
      {\shnu@answer@show{#1}{#2}}%               有参：按类型显示
  \else
    \IfNoValueTF{#1}
      {}%                                         无参 + 非答案模式：不显示
      {\shnu@answer@blank{#1}{#2}}%               有参 + 非答案模式：显示空白
  \fi
}

% solution 模式下按类型显示答案
\newcommand{\shnu@answer@show}[2]{%
  \IfStrEq{#1}{choice}{%
    ~\mbox{(\textcolor{red}{#2})}%
  }{%
    \IfStrEq{#1}{blank}{%
      ~\mbox{\underline{\textcolor{red}{#2}}}%
    }{%
      \par\noindent{\heiti 答案：}#2\par
    }%
  }%
}

% 非 solution 模式下显示答题空白
\newdimen\shnu@ans@wd
\newcommand{\shnu@answer@blank}[2]{%
  \IfStrEq{#1}{choice}{%
    ~\mbox{(\hspace{4em})}%
  }{%
    \IfStrEq{#1}{blank}{%
      \settowidth{\shnu@ans@wd}{#2}%
      ~\mbox{\underline{\hspace{\dimexpr\shnu@ans@wd+4em\relax}}}%
    }{}%
  }%
}

\endinput
