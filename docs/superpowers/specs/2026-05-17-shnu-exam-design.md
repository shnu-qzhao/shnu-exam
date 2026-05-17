# SHNU-Exam LaTeX 文档类设计规格

## 概述

为上海师范大学考试卷设计 LaTeX 文档类 `shnu-exam.cls`，基于 `ctexart`，使用 XeLaTeX 编译。精确还原原始试卷的版面格式。

## 字体配置

| 用途 | 中文字体 | 西文字体 | 大小 | 字重 |
|------|---------|---------|------|------|
| 试卷标题 ("上海师范大学标准试卷") | 黑体 SimHei | — | 22pt | 加粗 |
| 科目 / 大题标题 | 宋体 SimSun | Times New Roman | 15pt | 加粗 |
| 正文 | 宋体 SimSun | Times New Roman | 10.5pt (五号) | 常规 |
| 数学 | — | Times New Roman | 10.5pt | 常规 |
| 诚信承诺行 | 黑体 SimHei | — | 12pt | 常规 |

数学字体：TeX Gyre Termes Math（Times 风格兼容数学字体），通过 unicode-math 宏包加载。

## 页面布局

- 纸张：A4 (210mm × 297mm)
- 上边距：2.54cm (914400 EMU)
- 下边距：2.54cm (914400 EMU)
- 左边距：3.17cm (1141095 EMU)
- 右边距：3.17cm (1141095 EMU)
- 页眉：第 X 页 / 共 Y 页

## 试卷头行间距（精确匹配原文档）

原文档中每个段落有精确的行间距设定（Word "固定值"行距），需要在 LaTeX 中逐一匹配。

| 元素 | 字号 | 行距类型 | 精确基线距 | 段前间距 | 段后间距 | 对齐 |
|------|------|---------|-----------|---------|---------|------|
| 标题 "上海师范大学标准试卷" | 22pt | 单倍 | ~22pt | 0 | 0 | 居中 |
| 学年学期行 | 10.5pt | 固定值 18pt | 18pt | 0 | 0 | 居中 |
| 考试时间行 | 10.5pt | 固定值 18pt | 18pt | 0 | 7.8pt | 居中 |
| 科目行 | 15pt | 固定值 18pt | 18pt | 0 | 0 | 居中 |
| 学生信息行 | 10.5pt | 固定值 20pt | 20pt | 7.8pt | 7.8pt | 首行缩进10.5pt |
| 诚信承诺行 | 12pt | 单倍 | ~12pt | 23.4pt | 15.6pt | 居中 |
| 空行 | — | — | — | — | — | — |

关键数值的 EMU 转换：
- 18pt = 228600 EMU（学年、时间、科目行行距）
- 20pt = 254000 EMU（学生信息行行距）
- 7.8pt = 99060 EMU（小间距）
- 23.4pt = 297180 EMU（承诺行前间距）
- 15.6pt = 198120 EMU（承诺行后间距）
- 10.5pt = 133350 EMU（首行缩进量）

## 正文行间距

正文（题目内容）使用 1.5 倍行距。LaTeX 中通过 `\linespread{1.5}` 或 `setspace` 宏包的 `\onehalfspacing` 实现。

## 文档类选项

```latex
\documentclass[
  answerspace=10,    % 大题默认答题空白行数（默认10）
  showscore=true,    % 是否显示得分表和得分栏（默认true）
  solution=false,    % 是否显示答案解析（默认false）
]{shnu-exam}
```

## 核心用户命令

### 试卷信息命令

```latex
\examtitle{概率论与数理统计}        % 科目名称
\examtype{A卷}                      % 卷型
\semester{2025~2026 学年~~第~1~学期} % 学年学期
\examdate{2026年1月13日}            % 考试日期
\examduration{90}                   % 考试时间（分钟）
```

### 大题命令

```latex
\section{选择题（每小题2分，共16分）}
\section{填空题（每空3分，共24分）}
\section{计算题（本题10分）}
```

每个 `\section` 自动：
- 在得分表中添加一列
- 在标题旁生成得分栏
- 使用宋体加粗 15pt 字体

### 选择题命令

```latex
\question 题干内容...
  \choice{选项A内容}
  \choice{选项B内容}
  \choice{选项C内容}
  \choice{选项D内容}
```

`\choice` 自动布局算法（两遍编译）：
1. 第一遍：将四个选项的宽度写入 `.aux` 文件
2. 第二遍：读取宽度，根据规则排布：
   - 最长选项 ≤ 0.22\linewidth → **4列一行**（用 tabularx 或 \quad 分隔）
   - 最长选项 ≤ 0.45\linewidth → **2×2 网格**（两行，每行两项）
   - 否则 → **每项一行**（4行，每行一项）

手动覆盖：`\choice*[layout=4inrow|2x2|4row]{选项内容}`

### 填空题命令

```latex
\question 题干内容 \fillin
% 或带答案（solution=true时显示）
\question 题干内容 \fillin[答案]
```

### 解答题命令

```latex
\problem[lines=15] 题干内容...   % 预留15行空白
\problem[space=6cm] 题干内容...  % 预留6cm空白
\problem 题干内容...             % 使用全局answerspace默认值
```

## 自动生成元素

### 得分表

位于试卷头下方、诚信承诺行上方。格式：

```
| 题号 | 一 | 二 | 三 | 四 | 五 | 六 | 总分 |
| 得分 |   |   |   |   |   |   |      |
```

- 列数根据 `\section` 数量自动确定
- 使用 `tabularx` 自动计算列宽
- "得分"栏占位由用户手写批分

### 页眉

自动生成 "第 X 页 / 共 Y 页" 格式的页眉。

### 诚信承诺行

固定文本："我承诺，遵守《上海师范大学考场规则》，诚信考试。  签名：________________"

### 得分栏

每道大题标题右侧显示 "得分" 标签，采用 flushright 对齐。

## 文件结构

```
C:\Users\Zhao\Projects\SHNU-Exam\
├── shnu-exam.cls           # 文档类主体
├── example-basic.tex       # 基础示例模板
├── example-2026-1-A.tex    # 还原原试卷的完整示例
└── README.html             # 使用说明（HTML格式，中文）
```

## 依赖宏包

- `ctex` — 中文支持
- `fontspec` — 字体配置
- `unicode-math` — 数学字体
- `geometry` — 页面设置
- `fancyhdr` — 页眉页脚
- `tabularx` — 得分表
- `enumitem` — 列表格式
- `setspace` — 行距控制
- `calc` — 长度计算
- `environ` — 环境封装
- `lastpage` — 总页数获取

## 编译要求

- 编译器：XeLaTeX
- 编译次数：2次（第一遍写入选项宽度到 .aux，第二遍读取并确定布局）
