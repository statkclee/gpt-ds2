# Claude API 가격 표 (gt 패키지 사용)
# 2025년 1월 기준

library(gt)
library(dplyr)

# 1. 기본 모델 가격 데이터
claude_pricing <- tibble::tribble(
  ~model_family, ~model_name, ~input_per_mtok, ~output_per_mtok, ~status,

  # Claude 4.5 시리즈 (최신)
  "Claude 4.5", "Opus 4.5", 5.00, 25.00, "최신",
  "Claude 4.5", "Sonnet 4.5", 3.00, 15.00, "최신",
  "Claude 4.5", "Sonnet 4.5 (>200K)", 6.00, 22.50, "최신 (장문맥락)",
  "Claude 4.5", "Haiku 4.5", 1.00, 5.00, "최신",

  # Claude 4.x 시리즈 (이전 버전)
  "Claude 4.x", "Opus 4.1", 15.00, 75.00, "이전 버전",
  "Claude 4.x", "Opus 4", 15.00, 75.00, "이전 버전",
  "Claude 4.x", "Sonnet 4", 3.00, 15.00, "이전 버전",

  # Claude 3.x 시리즈 (레거시)
  "Claude 3.x", "Opus 3", 15.00, 75.00, "지원 종료",
  "Claude 3.x", "Sonnet 3.7", 3.00, 15.00, "지원 종료",
  "Claude 3.x", "Haiku 3.5", 0.80, 4.00, "현역",
  "Claude 3.x", "Haiku 3", 0.25, 1.25, "현역"
)

# 2. 배치 API 가격 (50% 할인)
batch_pricing <- claude_pricing %>%
  filter(status == "최신") %>%
  mutate(
    input_per_mtok = input_per_mtok * 0.5,
    output_per_mtok = output_per_mtok * 0.5
  ) %>%
  select(-status)

# 3. 기본 가격표 생성
pricing_table <- claude_pricing %>%
  gt(groupname_col = "model_family") %>%
  tab_header(
    title = "Claude API 사용료",
    subtitle = "2025년 1월 기준 (USD)"
  ) %>%
  cols_label(
    model_name = "모델",
    input_per_mtok = "입력 ($/MTok)",
    output_per_mtok = "출력 ($/MTok)",
    status = "상태"
  ) %>%
  fmt_currency(
    columns = c(input_per_mtok, output_per_mtok),
    currency = "USD",
    decimals = 2
  ) %>%
  tab_style(
    style = cell_fill(color = "#f0f0f0"),
    locations = cells_row_groups()
  ) %>%
  tab_style(
    style = cell_text(weight = "bold"),
    locations = cells_row_groups()
  ) %>%
  tab_style(
    style = list(
      cell_fill(color = "#e8f5e9"),
      cell_text(weight = "bold")
    ),
    locations = cells_body(
      columns = everything(),
      rows = status == "최신"
    )
  ) %>%
  tab_style(
    style = cell_fill(color = "#fff3e0"),
    locations = cells_body(
      columns = everything(),
      rows = status == "이전 버전"
    )
  ) %>%
  tab_style(
    style = list(
      cell_fill(color = "#ffebee"),
      cell_text(style = "italic", color = "#999")
    ),
    locations = cells_body(
      columns = everything(),
      rows = status == "지원 종료"
    )
  ) %>%
  tab_footnote(
    footnote = "MTok = Million Tokens (백만 토큰)",
    locations = cells_column_labels(columns = input_per_mtok)
  ) %>%
  tab_footnote(
    footnote = "Sonnet 4.5 장문맥락: 입력 토큰 200K 초과 시 자동 적용",
    locations = cells_body(
      columns = model_name,
      rows = model_name == "Sonnet 4.5 (>200K)"
    )
  ) %>%
  tab_footnote(
    footnote = "배치 API 사용 시 입력/출력 모두 50% 할인",
    locations = cells_title(groups = "title")
  ) %>%
  tab_source_note(
    source_note = "출처: https://platform.claude.com/docs/en/about-claude/pricing"
  ) %>%
  tab_source_note(
    source_note = "녹색: 최신 모델 | 주황색: 이전 버전 | 빨강색: 지원 종료 예정"
  ) %>%
  opt_align_table_header(align = "left")

# 4. 배치 API 가격표
batch_table <- batch_pricing %>%
  gt(groupname_col = "model_family") %>%
  tab_header(
    title = "Claude Batch API 사용료 (50% 할인)",
    subtitle = "비동기 대량 처리 전용"
  ) %>%
  cols_label(
    model_name = "모델",
    input_per_mtok = "입력 ($/MTok)",
    output_per_mtok = "출력 ($/MTok)"
  ) %>%
  fmt_currency(
    columns = c(input_per_mtok, output_per_mtok),
    currency = "USD",
    decimals = 2
  ) %>%
  tab_style(
    style = cell_fill(color = "#f0f0f0"),
    locations = cells_row_groups()
  ) %>%
  tab_style(
    style = cell_text(weight = "bold"),
    locations = cells_row_groups()
  ) %>%
  tab_footnote(
    footnote = "시간에 민감하지 않은 대량 작업에 적합",
    locations = cells_title(groups = "subtitle")
  ) %>%
  tab_source_note(
    source_note = "Batch API는 일반 API 대비 50% 저렴하지만 즉시 응답하지 않음"
  )

# 5. 프롬프트 캐싱 가격표
caching_multipliers <- tibble::tribble(
  ~cache_type, ~multiplier, ~description,
  "기본 입력", 1.00, "캐싱 없이 일반 입력",
  "5분 캐시 쓰기", 1.25, "캐시에 저장 (5분 지속)",
  "1시간 캐시 쓰기", 2.00, "캐시에 저장 (1시간 지속)",
  "캐시 읽기", 0.10, "캐시에서 재사용 (90% 절약)"
)

caching_table <- caching_multipliers %>%
  gt() %>%
  tab_header(
    title = "프롬프트 캐싱 가격 배수",
    subtitle = "기본 입력 가격 대비"
  ) %>%
  cols_label(
    cache_type = "캐싱 유형",
    multiplier = "배수",
    description = "설명"
  ) %>%
  fmt_number(
    columns = multiplier,
    decimals = 2
  ) %>%
  tab_style(
    style = list(
      cell_fill(color = "#e8f5e9"),
      cell_text(weight = "bold")
    ),
    locations = cells_body(
      columns = everything(),
      rows = cache_type == "캐시 읽기"
    )
  ) %>%
  tab_footnote(
    footnote = "예: Opus 4.5 기본 입력 $5 → 캐시 읽기 $0.50 (10배 절약)",
    locations = cells_body(
      columns = cache_type,
      rows = cache_type == "캐시 읽기"
    )
  )

# 6. 비용 예시 계산표
cost_examples <- tibble::tribble(
  ~use_case, ~model, ~input_tokens, ~output_tokens, ~cost,
  "간단한 질문", "Haiku 4.5", 100, 200, (100 * 1.00 + 200 * 5.00) / 1000000,
  "데이터 분석", "Sonnet 4.5", 5000, 2000, (5000 * 3.00 + 2000 * 15.00) / 1000000,
  "긴 문서 요약", "Sonnet 4.5", 50000, 5000, (50000 * 3.00 + 5000 * 15.00) / 1000000,
  "복잡한 추론", "Opus 4.5", 10000, 5000, (10000 * 5.00 + 5000 * 25.00) / 1000000,
  "배치 처리 (1000건)", "Haiku 4.5 Batch", 100000, 50000, (100000 * 0.50 + 50000 * 2.50) / 1000000
)

example_table <- cost_examples %>%
  gt() %>%
  tab_header(
    title = "Claude API 비용 예시",
    subtitle = "일반적인 사용 사례별 예상 비용"
  ) %>%
  cols_label(
    use_case = "사용 사례",
    model = "모델",
    input_tokens = "입력 토큰",
    output_tokens = "출력 토큰",
    cost = "예상 비용"
  ) %>%
  fmt_number(
    columns = c(input_tokens, output_tokens),
    decimals = 0,
    use_seps = TRUE
  ) %>%
  fmt_currency(
    columns = cost,
    currency = "USD",
    decimals = 4
  ) %>%
  tab_footnote(
    footnote = "1 토큰 ≈ 0.75 단어 (영어 기준), 한글은 약 0.5 단어",
    locations = cells_column_labels(columns = input_tokens)
  )

# 표 출력
print(pricing_table)
print(batch_table)
print(caching_table)
print(example_table)

# HTML 저장
# gtsave(pricing_table, "claude_pricing.html")
# gtsave(batch_table, "claude_batch_pricing.html")
# gtsave(caching_table, "claude_caching_pricing.html")
# gtsave(example_table, "claude_cost_examples.html")
