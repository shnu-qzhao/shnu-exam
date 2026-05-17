# SHNU-Exam：上海师范大学考试卷 LaTeX 文档类

基于 `ctexart`，使用 XeLaTeX 编译。精确还原上海师范大学标准试卷格式。

## 快速开始

```latex
% 基础用法（无答案）
\documentclass[answerspace=14]{shnu-exam}

% 带答案版本
\documentclass[solution=true,answerspace=14]{shnu-exam}

\examtitle{概率论与数理统计}
\examtype{A卷}
\semester{2025 $\sim$ 2026 学年~~第~1~学期}
\examdate{2026年1月13日}
\examduration{90}

\begin{document}
\maketitle

\section{一、选择题（每小题2分，共16分）}

\question 题干内容\answer[choice]{D}.
\choice{选项A}
\choice{选项B}
\choice{选项C}
\choice{选项D}

\section{二、填空题（每空3分，共24分）}

\question 题干\answer[blank]{答案}.

\section{三、计算题（本题10分）}

\problem[lines=12]{题干内容}

\section[newpage]{四、计算题（本题16分）}

\problem[lines=18]{题干\par 小问(1)\par 小问(2)}

\end{document}
```

编译：

```bash
xelatex example.tex    # 第一次
xelatex example.tex    # 第二次（生成完整得分表）
```

## 编译要求

- **编译器**：XeLaTeX（必须，需要中文字体支持）
- **编译次数**：2 次（首次生成 `.aux`，第二次得分表完整显示）
- **TeX 发行版**：TeX Live 2024+（含 ctex、fontspec、newtxmath 等宏包）
- **系统字体**：宋体 (SimSun)、黑体 (SimHei)、Times New Roman（Windows 自带）

## 文档类选项

| 选项 | 默认值 | 说明 |
|------|--------|------|
| `answerspace=10` | `10` | 大题默认答题空白行数 |
| `showscore=true` | `true` | 是否显示得分表和得分栏 |
| `solution=false` | `false` | `true` 时显示答案 |

## 试卷信息命令

| 命令 | 说明 |
|------|------|
| `\examtitle{科目}` | 科目名称 |
| `\examtype{A卷}` | 卷型 |
| `\semester{学年~~学期}` | 学年学期（`~~` 为不可断空格） |
| `\examdate{日期}` | 考试日期 |
| `\examduration{90}` | 考试时长（分钟） |
| `\maketitle` | 生成试卷头 + 得分表 + 诚信承诺行 |

波浪线 `~` 在 LaTeX 中为不可断空格。要显示可见波浪线请用 `$\sim$`：

```latex
\semester{2025 $\sim$ 2026 学年~~第~1~学期}
```

## 大题命令

```latex
% 普通大题（接排）
\section{一、选择题（每小题2分，共16分）}

% 从新页开始的大题
\section[newpage]{四、计算题（本题16分）}
```

每个 `\section` 自动：
- 计入得分表（第二次编译生效）
- 在标题同行左侧显示打分框（两列表格：得分 + 空）
- 重置题目编号为 1

题头为小四号（12pt）宋体加粗。

## 选择题

```latex
\question 题干\answer[choice]{D}.
\choice{选项A}
\choice{选项B}
\choice{选项C}
\choice{选项D}
```

选项根据长度自动排版：
- 四项总宽 < 行宽 1/4：**一行四列**
- 单项宽 < 半行但四项放不下：**2×2 网格**（B、D 从行中间开始）
- 单项过长：**每项一行**

## 填空题

```latex
\question 题干\answer[blank]{0.6}.
```

## 解答题

```latex
% 使用全局默认行数
\problem{题干}

% 指定空白行数
\problem[lines=15]{题干}

% 指定空白高度
\problem[space=6cm]{题干}

% 多段题干（用 \par 换段）
\problem[lines=18]{设二维随机变量...
\par (1) 第一小问；
\par (2) 第二小问。}
```

> 注意：`\problem` 参数内不能有空行，换段请用 `\par`。

## 答案系统

### `\answer` 命令

| 用法 | 无 `solution` 时 | `solution=true` 时 |
|------|-----------------|-------------------|
| `\answer[choice]{D}` | `(    )` | `(D)` 红色 |
| `\answer[blank]{0.6}` | 下划线（自动比答案宽 4 字符） | `0.6` 红色下划线 |
| `\answer{段落内容}` | 不显示 | 黑体"答案："+ 内容 |

答案不会跨行断开——括号和下划线均包在 `\mbox` 内。

## 格式规格

### 字体

| 元素 | 字体 | 大小 |
|------|------|------|
| 试卷标题 | 黑体加粗 (SimHei + FakeBold) | 22pt |
| 科目 | 宋体加粗 (SimSun + FakeBold) | 15pt |
| 大题标题 | 宋体加粗 (SimSun + FakeBold) | 12pt（小四） |
| 正文 | 宋体 + Times New Roman | 10.5pt（五号） |
| 数学 | Times 风格（newtxmath） | 10.5pt |
| 诚信承诺 | 黑体 | 12pt |
| 页脚 | 宋体 | 10.5pt（五号） |

### 页面

- A4 (210mm × 297mm)
- 上/下边距 2.54cm，左/右边距 3.17cm
- 页脚居中："第 X 页/共 Y 页"，无横线

### 行距

| 元素 | 行距 |
|------|------|
| 标题 | 22pt 单倍 |
| 学年/时间 | 15pt 固定 |
| 科目 | 16pt 固定 |
| 学生信息 | 16pt 固定 |
| 正文 | 1.55 倍 |
| 诚信承诺 | 12pt 单倍 |

### 学生信息行

格式：`____专业 本科____级___班 姓名____ 学号_______`

下划线宽度分别对应：专业名 (8em)、年份 (3.5em)、班级 (2.5em)、姓名 (4.5em)、学号 (8em)。

## 文件清单

| 文件 | 说明 |
|------|------|
| `shnu-exam.cls` | 文档类主体 |
| `example-2026-1-A.tex` | 完整示例 |
| `README.md` | 使用说明 |

## 注意事项

1. **编译两次**：首次编译得分表仅显示"题号 \| 总分"，第二次完整显示各列
2. **PDF 锁定**：编译前请关闭 PDF 查看器，否则 xelatex 无法写入
3. **`~` 与 `$\sim$`**：前者是不可断空格，后者是可见波浪线
4. **`\par` 与空行**：`\problem` 和 `\answer` 内不能有空行，换段用 `\par`
5. **公式不换行**：行内公式默认禁止在关系符和二元运算符处断开
