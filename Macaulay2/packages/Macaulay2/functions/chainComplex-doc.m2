--- status: DRAFT
--- author(s): MES
--- notes: 

document {
     Key => chainComplex,
     Headline => "make a chain complex",
     TT "chainComplex", " -- a method for creating chain complexes.",
     }

document { 
     Key => {(chainComplex,List),(chainComplex,Sequence)},
     Headline => "make a chain complex",
     Usage => {TT "C = chainComplex{f1,f2,f3,...} ", EM "or", TT " C = chainComplex(f1,f2,f3,...)"},
     Inputs => {
	  "f1,f2,f3,..." => "homomorphisms over the same ring, forming a complex",
	  },
     Outputs => {
	  "C" => ChainComplex => "the given complex, where f1 == C.dd_1, f2 = CC.dd_2, etc."
	  },
     "The maps f1, f2, ... must be defined over the same base ring, and they must form
     a complex: the target of f(i+1) is the source of fi.",
     PARA{},
     "The following example illustrates how chainComplex adjusts the degrees of
     the modules involved to ensure that sources and targets of the differentials
     correspond exactly.",
     EXAMPLE {
	  "R = ZZ/101[x,y]",
      	  "C = chainComplex{matrix{{x,y}},matrix{{x*y},{-x^2}}}",
	  },
     "We check that that this is a complex:",
     EXAMPLE {
	  "C.dd^2 == 0"
	  },
     "The homology of this complex:",
     EXAMPLE {
	  "HH C"
	  },
     Caveat => {},
     SeeAlso => {"chain complexes"}
     }

document { 
     Key => (chainComplex,GradedModule),
     Headline => "make a chain complex from a graded module",
     Usage => "chainComplex M",
     Inputs => {
	  "M" => null
	  },
     Outputs => {
	  {"the chain complex made from ", TT "M", " by installing the zero map as differential" }
	  },
     SeeAlso => {"chain complexes"}
     }

document { 
     Key => (chainComplex,Matrix),
     Headline => "make a small chain complex",
     Usage => "chainComplex f",
     Inputs => {
	  "f" => null
	  },
     Outputs => {
	  {"a chain complex with the map ", TT "f", " serving as the differential ", TT "C.dd_1"}
	  },
     EXAMPLE {
	  "R = QQ[x,y];",
	  "f = vars R",
	  "chainComplex f",
	  "HH oo"
	  },
     SeeAlso => {"chain complexes"}
     }
