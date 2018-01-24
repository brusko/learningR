## BaseballMunging
##
##

library(Lahman)

dim(Teams)

mets <- Teams %>% filter(teamID == 'NYN')
mymets <- mets %>% filter(YearID %in% 2004:2012)

# Get Wins & Losses
nymets %>% select(yearID, teamID, W,L)

### Better living wiht Pipes

mymets <- Teams %>% 
  select(yearID, teamID, W, L) %>% 
  filter(teamID == 'NYN' & yearID %in% 2004:2012)

## aiming to calculate the "Expected Winning Percentage"
## based on runs scored and runs allowed. 

metsBen <- Teams %>% 
  select(yearID, teamID, W, L, R, RA) %>% 
  filter(teamID == 'NYN' & yearID %in% 2004:2012)

metsBen <- metsBen %>% rename(RS = R)

## Add the winning percentage for each year
metsBen <- metsBen %>% mutate(WPct = W/(W+L))

## Add the EWP model
metsBen <- metsBen %>% mutate(EWP = 1 / (1 + (RA/RS)^2))

## Now, the expected number of wins == EWP * NumGames
metsBen <- metsBen %>% mutate(EWins = EWP * (W+L))

##############################3

manny <- filter(Batting, playerID == "ramirma02")

manny %>% group_by(teamID) %>% 
  summarize(
  span = paste(min(yearID), max(yearID), sep = "-"),
  numYears = n_distinct(yearID), 
  numTeams = n_distinct(teamID),
  BA = sum(H)/sum(AB), 
  tH = sum(H), 
  tHR = sum(HR), 
  tRBI = sum(RBI)) %>% 
  arrange(span)


Master %>% filter(nameLast == "Ramirez" & nameFirst == "Manny")

Master %>% filter(nameLast == "Mantle" & nameFirst == "Mickey")

mantle <- filter(Batting, playerID == 'mantlmi01')


Batting %>%
  filter(playerID == "mantlmi01") %>%
  inner_join(Master, by = c("playerID" = "playerID")) %>%
  group_by(yearID) %>%
  summarize(
    Age = max(yearID - birthYear), numTeams = n_distinct(teamID),
    BA = sum(H)/sum(AB), tH = sum(H), tHR = sum(HR), tRBI = sum(RBI)) %>%
  arrange(yearID)


mantleBySeason  <- Batting %>%
  filter(playerID == "mantlmi01") %>%
  inner_join(Master, by = c("playerID" = "playerID")) %>%
  group_by(yearID) %>%
  summarize(
    Age = max(yearID - birthYear), numTeams = n_distinct(teamID),
    BA = sum(H)/sum(AB), tH = sum(H), tHR = sum(HR), tRBI = sum(RBI),
    OBP = sum(H + BB + HBP) / sum(AB + BB + SF + HBP),
    SLG = sum(H + X2B + 2*X3B + 3*HR) / sum(AB)) %>%
  mutate(OPS = OBP + SLG) %>%
  arrange(yearID)
