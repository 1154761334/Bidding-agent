#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo 'Usage: bash scripts/generate-parse-skeleton.sh <workspace-dir> <project-id>' >&2
  exit 1
fi

WORKSPACE_DIR="$1"
PROJECT_ID="$2"
PROJECT_INPUT_DIR="$WORKSPACE_DIR/bid-vault/inbox/projects/$PROJECT_ID"
RUN_DIR="$WORKSPACE_DIR/bid-vault/output/project-runs/$PROJECT_ID"
NORMALIZED_DIR="$RUN_DIR/normalized"
MANIFEST_PATH="$RUN_DIR/00-NORMALIZATION-MANIFEST.md"
INDEX_PATH="$NORMALIZED_DIR/normalization-index.tsv"
GENERATED_PARSE_PATH="$RUN_DIR/02-TENDER-PARSE.generated.md"
PARSE_INPUT_INDEX_PATH="$RUN_DIR/parse-input-index.tsv"
FORMAL_PARSE_PATH="$RUN_DIR/02-TENDER-PARSE.md"
TARGET_STATUS='existing parse preserved'

if [ ! -d "$PROJECT_INPUT_DIR" ]; then
  echo "Project input folder not found: $PROJECT_INPUT_DIR" >&2
  echo 'Run bash scripts/new-project-inbox.sh <workspace-dir> <project-id> first.' >&2
  exit 1
fi

if [ ! -d "$RUN_DIR" ]; then
  echo "Project run folder not found: $RUN_DIR" >&2
  echo 'Run bash scripts/init-project-run.sh <workspace-dir> <project-id> first.' >&2
  exit 1
fi

if [ ! -f "$MANIFEST_PATH" ]; then
  echo "Normalization manifest not found: $MANIFEST_PATH" >&2
  echo 'Run bash scripts/init-project-run.sh <workspace-dir> <project-id> first.' >&2
  exit 1
fi

if [ ! -f "$INDEX_PATH" ]; then
  echo "Normalization index not found: $INDEX_PATH" >&2
  echo 'Run bash scripts/normalize-project-inputs.sh <workspace-dir> <project-id> first.' >&2
  exit 1
fi

python3 - "$PROJECT_ID" "$PROJECT_INPUT_DIR" "$MANIFEST_PATH" "$INDEX_PATH" "$GENERATED_PARSE_PATH" "$PARSE_INPUT_INDEX_PATH" <<'PY'
import csv
import datetime as dt
import pathlib
import sys

project_id = sys.argv[1]
project_input_dir = pathlib.Path(sys.argv[2])
manifest_path = pathlib.Path(sys.argv[3])
index_path = pathlib.Path(sys.argv[4])
generated_parse_path = pathlib.Path(sys.argv[5])
parse_input_index_path = pathlib.Path(sys.argv[6])

rows = []
with index_path.open(newline="", encoding="utf-8") as fh:
    reader = csv.DictReader(fh, delimiter="\t")
    for row in reader:
        bundle_dir = pathlib.Path(row["bundle_dir"])
        row["source_md"] = str(bundle_dir / "source.md")
        row["review_required"] = "yes" if row["status"] != "success" else "no"
        rows.append(row)

with parse_input_index_path.open("w", encoding="utf-8", newline="") as fh:
    writer = csv.writer(fh, delimiter="\t", lineterminator="\n")
    writer.writerow(
        [
            "input_category",
            "input_file",
            "adapter",
            "status",
            "review_required",
            "source_md",
            "bundle_dir",
            "notes",
        ]
    )
    for row in rows:
        writer.writerow(
            [
                row["input_category"],
                row["input_file"],
                row["adapter"],
                row["status"],
                row["review_required"],
                row["source_md"],
                row["bundle_dir"],
                row["notes"],
            ]
        )

categories = [
    "tender",
    "addenda",
    "company-inputs",
    "vendor-inputs",
    "project-attachments",
    "notes",
]

grouped = {category: [] for category in categories}
for row in rows:
    grouped.setdefault(row["input_category"], []).append(row)

success_rows = [row for row in rows if row["status"] == "success"]
warning_rows = [row for row in rows if row["status"] == "warning"]
failed_rows = [row for row in rows if row["status"] == "failed"]
review_rows = [row for row in rows if row["review_required"] == "yes"]

def short_item(row):
    return f"`{row['input_category']}/{row['input_file']}` [{row['status']} via {row['adapter']}]"

def format_inline(category):
    items = grouped.get(category, [])
    if not items:
        return "无"
    return "；".join(short_item(item) for item in items)

def format_block(items):
    if not items:
        return "- 无\n"
    return "".join(f"- {short_item(item)}\n" for item in items)

def category_section(category):
    return f"""### {category}
{format_block(grouped.get(category, []))}"""

generated = f"""# 招标解析页（自动骨架）

> 自动生成时间：{dt.datetime.now().isoformat(timespec="seconds")}
> 项目编号：`{project_id}`
> 说明：本文件只汇总标准化输入来源和待人工复核项，不做事实判断，不替代人工解析。

## 一、解析来源
- 当前项目输入目录：`{project_input_dir}`
- 招标文件：{format_inline("tender")}
- 补遗/澄清：{format_inline("addenda")}
- 项目专属附件：{format_inline("project-attachments")}
- 解析日期：{dt.date.today().isoformat()}

## 二、标准化来源清单

{category_section("tender")}
{category_section("addenda")}
{category_section("company-inputs")}
{category_section("vendor-inputs")}
{category_section("project-attachments")}
{category_section("notes")}

## 三、标准化状态汇总
- 成功：{len(success_rows)}
- Warning：{len(warning_rows)}
- Failed：{len(failed_rows)}
- 需要人工复核：{len(review_rows)}
- 标准化清单：`{manifest_path}`
- 机器索引：`{parse_input_index_path}`

## 四、待人工复核文件
{format_block(review_rows)}

## 五、包件与范围确认
- 是否多包：
- 目标包件/标段：
- 如未确认，当前阶段是否必须停止：
- 本项目响应边界：

## 六、资格性要求
- 必须满足的资格条件：
- 必须提交的证明材料：
- 资格风险点：

## 七、符合性与废标风险
- 关键符合性要求：
- 可能触发废标/否决的条款：
- 盖章/签字/密封/电子上传要求：

## 八、评分项提取

| 评分项/要求 | 分值 | 响应重点 | 是否需要证据 | 备注 |
| --- | --- | --- | --- | --- |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |

## 九、目录与交付要求
- 要求的响应文件结构：
- 商务/技术/报价文件拆分要求：
- 页数/格式/字体/装订要求：
- 原件/复印件/扫描件要求：

## 十、待澄清问题
- 尚未确认的包件/范围：
- 尚未确认的厂商/原厂材料：
- 尚未确认的风险边界：
- 缺失的项目输入文件：

## 十一、当前阶段结论
- 是否可进入证据整理：
- 是否需先补材料：
- 是否已满足“生成映射表与目录占位”的前置条件：
"""

generated_parse_path.write_text(generated, encoding="utf-8")
PY

if [ ! -f "$FORMAL_PARSE_PATH" ]; then
  cp "$GENERATED_PARSE_PATH" "$FORMAL_PARSE_PATH"
  TARGET_STATUS='copied to formal parse page because 02-TENDER-PARSE.md was missing'
fi

printf 'Generated parse skeleton: %s\n' "$GENERATED_PARSE_PATH"
printf 'Parse input index: %s\n' "$PARSE_INPUT_INDEX_PATH"
printf 'Formal parse page: %s (%s)\n' "$FORMAL_PARSE_PATH" "$TARGET_STATUS"
