hru4dig <- function(matrix, j = 1)  {
  ## function - add leading zero to three digit hru
  
  # hru is default in column 1, but can be in other columns
  for (i in 1:length(matrix[,j])) {
    if (as.numeric(matrix[i,j]) <= 999) {
      matrix[i,j] = paste0("0",matrix[i,j])
    } 
  }
  return(matrix)
}