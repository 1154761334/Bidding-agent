# 当前项目输入标准化清单

## 目的
- 本清单用于记录当前项目输入文件的标准化情况。
- 标准化产物仅服务于当前项目解析与起草，不等于长期知识页。
- 若标准化失败或文本质量不足，应在此明确记录，不得跳过风险提示。

## 标准化输出位置
- 项目运行目录：`bid-vault/output/project-runs/<project-id>/`
- 标准化产物目录：`bid-vault/output/project-runs/<project-id>/normalized/`
- 机器索引文件：`bid-vault/output/project-runs/<project-id>/normalized/normalization-index.tsv`

## 清单

| 输入类别 | 原始文件 | 标准化目录 | 适配器 | 状态 | 备注 |
| --- | --- | --- | --- | --- | --- |
| tender |  |  |  | 待处理 |  |
| addenda |  |  |  | 待处理 |  |
| company-inputs |  |  |  | 待处理 |  |
| vendor-inputs |  |  |  | 待处理 |  |
| project-attachments |  |  |  | 待处理 |  |

## 使用规则
1. 优先使用 `markitdown` 进行 Word/PDF/Excel/PPT 等文件的 Markdown 标准化。
2. `pandoc` 和 `pdftotext` 只作为兼容性 fallback，不构成单独架构层。
3. 原始文件始终保留在 `bid-vault/inbox/projects/<project-id>/`，标准化产物只放在项目运行目录。
4. 当前项目招标文件的标准化结果不能自动进入长期知识库。
