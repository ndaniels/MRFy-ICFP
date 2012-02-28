type HMMState = Int
type StatePath = [ HMMState ]
mat = 0 :: HMMState
ins = 1 :: HMMState
del = 2 :: HMMState
type EmissionProbabilities = V.Vector Double
data TransitionProbability (fState::HMMState, tState::HMMState) = 
     TransitionProbability { logProbability::LogProbability
                           , fromState = value fState::HMMState
                           , toState = value tState::HMMState
                           }
data TransitionProbabilities =
     TransitionProbabilities { m_m :: TransitionProbability
                             , m_i :: TransitionProbability
                             , m_d :: TransitionProbability
                             , i_m :: TransitionProbability
                             , i_i :: TransitionProbability
                             , d_m :: TransitionProbability
                             , d_d :: TransitionProbability
                             }
data HmmNode =
     HmmNode { nodeNum :: Int
             , matchEmissions :: EmissionProbabilities
             , insertionEmissions :: EmissionProbabilities
             , transitions :: TransitionProbabilities
             }
type HMM = V.Vector HmmNode