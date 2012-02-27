module StochasticSearch where
type Scorer = QuerySequence -> [BetaStrand] -> SearchGuess -> SearchSolution
data SearchStrategy = SearchStrategy { accept :: SearchParameters -> Seed -> History -> Age -> Bool
                                     , terminate :: SearchParameters -> History -> Age -> Bool
                                     , mutate :: SearchParameters -> Seed -> QuerySequence ->
                                        Scorer -> [BetaStrand] -> [SearchSolution] ->
                                        [SearchSolution]
                                     , initialize :: SearchParameters -> Seed ->
                                        QuerySequence -> [BetaStrand]-> [SearchGuess]
                                     }
search :: QuerySequence -> HMM -> [BetaStrand] -> SearchParameters -> [Seed] -> (SearchSolution, History)
search query hmm betas searchP seeds = search' (tail seeds) initialGuessScore [] 0
  where initialGuessScore = map (score hmm query betas) initialGuess
        initialGuess = initialize strat searchP (head seeds) query betas
        strat = strategy searchP
        search' :: [Seed] -> [SearchSolution] -> History -> Age ->
                   (SearchSolution, History)
        search' (s1:s2:seeds) oldPop hist age =
          let newPop = mutate' oldPop
              score = fst $ minimum newPop
              newHist = score : hist
            in if accept' newHist age then
                  if terminate' newHist age then
                    (minimum newPop, newHist)
                  else
                    search' seeds newPop newHist (age + 1)
               else
                 if terminate' hist age then
                   (minimum oldPop, hist)
                 else
                   search' seeds oldPop hist (age + 1)
            where mutate' = mutate strat searchP s1 query (score hmm) betas
                  terminate' = terminate strat searchP
                  accept' = accept strat searchP s2
