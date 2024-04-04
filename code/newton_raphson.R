# 2차방정식의 계수 (ax^2 + bx + c)
a <- 2
b <- -4
c <- 2

# 2차방정식의 도함수 (2ax + b)
derivative <- function(x) {
  2 * a * x + b
}

# 뉴튼-랩슨 방법으로 최소값 찾기
newton_raphson <- function(x0, tol = 1e-6, max_iter = 100) {
  x <- x0
  for (i in 1:max_iter) {
    x_new <- x - derivative(x) / (2 * a)
    if (abs(x_new - x) < tol) {
      return(x_new)
    }
    x <- x_new
  }
  return(x)
}

# 최소값 계산
x_min <- newton_raphson(0)

# 결과 출력
cat("2차방정식의 최소값:", x_min, "\n")
