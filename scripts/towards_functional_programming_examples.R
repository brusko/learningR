##

increment <- function(x) {
  return(x + 1)
}

increment_opaque <- function(x) {
  return(x + spam)
}

increment_not_opaque <- function(x, spam) {
  return(x + spam)
}

count_iter <- 0

sqrt_newton_side_effect <- function(a, init, eps = 0.01){
  while(abs(init**2 - a) > eps){
   init <- 1/2 *(init + a/init)
     count_iter <<- count_iter + 1 # The "<<-" symbol means that we assign the
    } # RHS value in a variable in the global environment
   return(init)
   }


## iteration (looping)
sqrt_newton <- function(a, init, eps = 0.01){
  while(abs(init**2 - a) > eps) {
    init <- 1/2*(init + a/init)
   # print(init)
    }
  return(init)
}

sqrt_newton <- function(a, init, eps = 0.01){
   while(abs(init**2 - a) > eps){
     init <- 1/2 *(init + a/init)
     }
   return(init)
  }


## recursion

sqrt_newton_recur <- function(a, init, eps = 0.01){
  if(abs(init**2 - a) < eps){
    result = init
  } else{
    init <- 1/2*(init + a/init)
    print(init)
    result <- sqrt_newton_recur(a, init, eps)
  }
  return(result)
}


#### vectors

sqrt_newton_vec <- function(numbers, init, eps = 0.01){
  return(Map(sqrt_newton, numbers, init, eps))
}



## minimum of two numbers

my_min <- function(a,b){
  if(a < b) {
    return(a)
  } else{
    return(b)
  }
}


is_multiple_of_two <- function(x) {
  ifelse(x %% 2 == 0, TRUE, FALSE) 
}

map_if(a, is_multiple_of_two, sqrt)




for (i in a) {
  return(fac = )
}

my_fact <- function(n){
  reduce(1:n, `*`)
}
