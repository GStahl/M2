-- Copyright 1995-2002 by Michael Stillman

MonomialIdeal = new Type of Ideal
MonomialIdeal.synonym = "monomial ideal"
monomialIdeal = method(TypicalValue => MonomialIdeal,SingleArgumentDispatch=>true)
numgens MonomialIdeal := I -> I.numgens
raw MonomialIdeal := I -> I.RawMonomialIdeal
generators MonomialIdeal := (cacheValue symbol generators) ( (I) -> map(ring I, rawMonomialIdealToMatrix raw I) )

ideal MonomialIdeal := (I) -> ideal generators I
isIdeal MonomialIdeal := I -> true

newMonomialIdeal = (R,rawI) -> new MonomialIdeal from {
     symbol numgens => rawNumgens rawI,
     symbol RawMonomialIdeal => rawI,
     symbol cache => new CacheTable,
     symbol ring => R
     }

monomialIdealOfRow := (i,m) -> newMonomialIdeal(ring m,rawMonomialIdeal(raw m, i))

codim Module := M -> if M.cache.?codim then M.cache.codim else M.cache.codim = (
     R := ring M;
     if M == 0 then infinity
     else if isField R then 0
     else if R === ZZ then if M ** QQ == 0 then 1 else 0
     else (
	  p := generators gb presentation M;
	  n := rank target p;
	  c := infinity;
	  for i from 0 to n-1 when c > 0 do c = min(c,codim monomialIdealOfRow(i,p));
	  c - codim R)
     )

MonomialIdeal ^ ZZ := MonomialIdeal => (I,n) -> SimplePowerMethod(I,n)

Ring / MonomialIdeal := (R,I) -> R / ideal I

monomialIdeal MonomialIdeal := I -> (
     error "the function monomialIdeal applied to a MonomialIdeal has been removed")

monomialIdeal Matrix := MonomialIdeal => f -> (
     if numgens target f =!= 1 then error "expected a matrix with 1 row";
     monomialIdealOfRow(0,f))

monomialIdeal List := MonomialIdeal => v -> monomialIdeal matrix {splice v}
monomialIdeal Sequence := v -> monomialIdeal toList v

MonomialIdeal == MonomialIdeal := (m,n) -> m === n

MonomialIdeal == ZZ := (m,i) -> (
     if i === 0 then numgens m == 0
     else error "asked to compare monomial ideal to nonzero integer")
ZZ == MonomialIdeal := (i,m) -> m == i

MonomialIdeal + MonomialIdeal := MonomialIdeal => (I,J) -> (
     if ring I =!= ring J then error "expected monomial ideals in the same ring";
     newMonomialIdeal(ring I, raw I + raw J))
MonomialIdeal * MonomialIdeal := MonomialIdeal => (I,J) -> (
     if ring I =!= ring J then error "expected monomial ideals in the same ring";
     newMonomialIdeal(ring I, raw I * raw J))
MonomialIdeal - MonomialIdeal := MonomialIdeal => (I,J) -> (
     if ring I =!= ring J then error "expected monomial ideals in the same ring";
     newMonomialIdeal(ring I, raw I - raw J))

radical MonomialIdeal := MonomialIdeal => options -> (I) -> newMonomialIdeal(ring I, rawRadical raw I)

quotient(MonomialIdeal, MonomialIdeal) :=
MonomialIdeal : MonomialIdeal := MonomialIdeal => (I,J) -> newMonomialIdeal(ring I, rawColon(raw I, raw J))

saturate(MonomialIdeal, MonomialIdeal) := MonomialIdeal => o -> (I,J) -> newMonomialIdeal(ring I, rawSaturate(raw I, raw J))

saturate(MonomialIdeal, RingElement) := Ideal => o -> (I,f) -> (
     if size f === 1 and leadCoefficient f == 1 then saturate (I,monomialIdeal f)
     else saturate(ideal I, ideal f)
     )

int := (I,J) -> (
     if ring I =!= ring J then error "expected monomial ideals in the same ring";
     newMonomialIdeal(ring I, rawIntersect(raw I, raw J)))

intersect(List) := x -> intersect toSequence x

intersect(Sequence) := args -> (
    -- first check that all modules have the same target
    -- and the same base ring
    if #args === 0 then error "expected at least one argument";
    M := args#0;
    R := ring M;
    if class M === MonomialIdeal then (
	 if not all(args, M -> class M === MonomialIdeal and R === ring M)
	 then error "expected monomial ideals over the same ring";
	 i := 1;
	 while i < #args do (
	      M = int(M,args#i);
	      i = i+1;
	      );
	 M)
    else if class M === Module then (
    	 F := ambient args#0;
	 if not all(args, N -> ambient N == F)
	 or M.?relations 
	 and not all(args, N -> 
	      N.?relations 
	      and (N.relations == M.relations
		   or
		   image N.relations == image M.relations
		   )
	      )
    	 then error "all modules must be submodules of the same module";
    	 relns := directSum apply(args, N -> (
		   if N.?relations 
		   then generators N | N.relations
		   else generators N
		   )
	      );
    	 g := map(R^(#args),R^1, table(#args,1,x->1)) ** id_F;
	 h := modulo(g, relns);
	 if M.?relations then h = compress( h % M.relations );
    	 subquotient( h, if M.?relations then M.relations )
	 )
    else if class M === Ideal then (
	 ideal intersect apply(args,module)
	 )
    else error "expected modules, ideals, or monomial ideals"
    )

borel MonomialIdeal := MonomialIdeal => (I) -> newMonomialIdeal(ring I, rawStronglyStableClosure raw I)
isBorel MonomialIdeal := Boolean => m -> rawIsStronglyStable raw m
codim MonomialIdeal := m -> rawCodimension raw m

poincare MonomialIdeal := M -> (
     R := ring M;
     ZZn := degreesRing(R);
     if not M.cache.?poincare then
         M.cache.poincare = new ZZn from rawHilbert rawMonomialIdealToMatrix M.RawMonomialIdeal; 
     M.cache.poincare
     )

-- OBSOLETE
--minprimes MonomialIdeal := MonomialIdeal => m -> (
--     newMonomialIdeal(ring m, rawAssociatedPrimes m.RawMonomialIdeal))

independentSets = method(Options => { Limit => infinity })
independentSets MonomialIdeal := o -> (M) -> (
     result := newMonomialIdeal(ring M, 
	  rawMaximalIndependentSets(M.RawMonomialIdeal, 
	       if o.Limit === infinity then -1 else o.Limit));
     result = flatten entries generators result;
     if #result === 1 and result#0 == 1_(ring M) then 
         {}
	 -- result#0=1 means the single isolated 
	 -- prime is the maximal ideal
     else
         result
     )
independentSets Ideal := o -> (M) -> independentSets(monomialIdeal M,o)
     
     

-----------------------------------------------------------------------------
-- this code below here is by Greg Smith
-----------------------------------------------------------------------------

expression MonomialIdeal := (I) -> (
     if numgens I === 0 then hold "0" 
     else new FunctionApplication from { monomialIdeal, unsequence expression toSequence first( entries generators I) }
     )

MonomialIdeal.AfterPrint = MonomialIdeal.AfterNoPrint = (I) -> (
     << endl;				  
     << concatenate(interpreterDepth:"o") << lineNumber << " : MonomialIdeal of " 
     << ring I << endl;
     )

monomialIdeal Ideal :=  MonomialIdeal => (I) -> monomialIdeal generators gb I

monomialIdeal Module := MonomialIdeal => (M) -> (
     if isSubmodule M and rank ambient M === 1 
     then monomialIdeal generators gb M
     else error "expected a submodule of a free module of rank 1"
     )

monomialIdeal RingElement := MonomialIdeal => v -> monomialIdeal {v}
ring MonomialIdeal := I -> I.ring
numgens MonomialIdeal := I -> I.numgens
MonomialIdeal _ ZZ := (I,n) -> (generators I)_(0,n)
module MonomialIdeal := Module => (I) -> image generators I

isMonomialIdeal = method(TypicalValue => Boolean)
isMonomialIdeal Thing := x -> false
isMonomialIdeal MonomialIdeal := (I) -> true
isMonomialIdeal Ideal := (I) -> isPolynomialRing ring I and all(first entries generators I, r -> size r === 1 and leadCoefficient r == 1)

MonomialIdeal == Ideal := (I,J) -> ideal I == J
Ideal == MonomialIdeal := (I,J) -> I == ideal J

MonomialIdeal == Ring := (I,R) -> (
     if ring I =!= R then error "expected ideals in the same ring";
     1_R % I == 0)
Ring == MonomialIdeal := (R,I) -> I == R

MonomialIdeal + Ideal := Ideal => (I,J) -> ideal I + J
Ideal + MonomialIdeal := Ideal => (I,J) -> I + ideal J

RingElement * MonomialIdeal := MonomialIdeal => (r,I) -> monomialIdeal (r * generators I)
ZZ * MonomialIdeal := MonomialIdeal => (r,I) -> monomialIdeal (r * generators I)

MonomialIdeal * Ideal := Ideal => (I,J) -> ideal I * J
Ideal * MonomialIdeal := Ideal => (I,J) -> I * ideal J

MonomialIdeal * Module := Module => (I,M) -> ideal I * M

MonomialIdeal * Ring := Ideal => (I,S) -> if ring I === S then I else monomialIdeal(I.generators ** S)
Ring * MonomialIdeal := Ideal => (S,I) -> if ring I === S then I else monomialIdeal(I.generators ** S)

Matrix % MonomialIdeal := Matrix => (f,I) -> f % forceGB generators I
RingElement % MonomialIdeal := (r,I) -> r % forceGB generators I
ZZ % MonomialIdeal := (r,I) -> r_(ring I) % forceGB generators I

Matrix // MonomialIdeal := Matrix => (f,I) -> f // forceGB generators I
RingElement // MonomialIdeal := (r,I) -> r // forceGB generators I
ZZ // MonomialIdeal := (r,I) -> r_(ring I) // forceGB generators I

dim MonomialIdeal := I -> dim ring I - codim I

degree MonomialIdeal := I -> degree cokernel generators I   -- maybe it's faster with 'poincare'

jacobian MonomialIdeal := Matrix => (I) -> jacobian generators I

resolution MonomialIdeal := ChainComplex => options -> I -> resolution ideal I
betti MonomialIdeal := I -> betti ideal I


lcmgens := local lcmgens
alexanderdual := local alexanderdual

lcmOfGens := (I) -> if I.cache#?lcmgens then I.cache#lcmgens else I.cache#lcmgens = (
     max \ transpose apply(first entries generators I, i -> first exponents i)
     )



 -- We use E. Miller's definition for nonsquare 
 -- free monomial -- ideals.

dual(MonomialIdeal, List) := (I,a) -> ( -- Alexander dual
     R := ring I;
     X := generators R;
     aI := lcmOfGens I;
     if aI =!= a then (
     	  if #aI =!= #a 
	  then error (
	       "expected list of length ",
	       toString (#aI));
	  scan(a, aI, 
	       (b,c) -> (
		    if b<c then
		    error "exponent vector not large enough"
		    ));
	  );
     P := monomialIdeal apply(#X, i -> X#i^(a#i+1));
     monomialIdeal( (generators (P:I)) % P )
     )

dual(MonomialIdeal,RingElement) := (I,r) -> dual(I,first exponents r)

dual MonomialIdeal := (I) -> (
  if I.cache#?alexanderdual
    then I.cache#alexanderdual
    else I.cache#alexanderdual = (
	 d := lcmOfGens(I);
	 if max d === 1 then minimalPrimes I
	 else dual(I, lcmOfGens(I))
    ))

--  ASSOCIATED PRIMES  -------------------------------------
ass0 := (I) -> (
     if I.cache#?associatedPrimes
     then I.cache#associatedPrimes
     else I.cache#associatedPrimes = (
     	  R := ring I;
     	  J := dual I;
     	  M := first entries generators J;
	  H := new MutableHashTable;
     	  scan(M, m -> (
		    s := rawIndices raw m;
		    if not H#?s then H#s = true));
	  inds := sort apply(keys H, ind -> (#ind, ind));
	  apply(inds, s -> s#1)
     ))

associatedPrimes MonomialIdeal := List => o -> (I) -> (
     inds := ass0 I;
     R := ring I;
     apply(inds, ind -> monomialIdeal apply(ind, v -> R_v)))

--  PRIMARY DECOMPOSITION  ---------------------------------

minimalPrimes = method()
minimalPrimes MonomialIdeal := (I) -> (
     (J,Js,Qs,ans,i) := null;
     J = radical I;
     if gbTrace > 0 then (
       time Js = apply(numgens J, i -> J_i);
       time Qs = apply(Js, i -> monomialIdeal support(i));
       ans = Qs_0;
       i = 1;
       time while i < #Qs do (
     	  time ans = intersect(ans,Qs_i);
     	  << "i = " << i << " numgens " << numgens ans << endl;
     	  i = i+1;
     	  );
       ans)
     else (
       Js = apply(numgens J, i -> J_i);
       Qs = apply(Js, i -> monomialIdeal support(i));
       ans = Qs_0;
       i = 1;
       while i < #Qs do (
     	  ans = intersect(ans,Qs_i);
     	  i = i+1;
     	  );
       ans)
     )

irreducibleDecomposition = method();
irreducibleDecomposition MonomialIdeal := List => (I) -> (
     R := ring I;
     aI := lcmOfGens I;
     M := first entries generators dual I;
     apply(M, m -> (
	       s := first keys standardForm leadMonomial m;
	       monomialIdeal apply(keys s, v -> R_v^(aI#v + 1 - s#v))))
     )

primaryDecomposition MonomialIdeal := List => o -> (I) -> (
     R := ring I;
     aI := lcmOfGens I;
     J := dual I;
     M := first entries generators J;
     H := new MutableHashTable;
     scan(M, m -> (
	       s := first keys standardForm leadMonomial m;
	       Q := monomialIdeal apply(keys s, v -> R_v^(aI#v + 1 - s#v));
	       ind := sort keys s;
	       if not H#?ind then H#ind = Q
	       else H#ind = intersect(H#ind,Q)));
     apply(ass0 I, ind -> H#ind)
     )


--  TESTING IF A THING IS A SQUARE FREE MONOMIAL IDEAL  ----
isSquareFree = method(TypicalValue => Boolean)		    -- could be isRadical?
-- isSquareFree Thing := x -> false
isSquareFree MonomialIdeal := (I) -> all(first entries generators I, m -> all(first exponents m, i -> i<2))

--  STANDARD PAIR DECOMPOSITION  ---------------------------
-- algorithm 3.2.5 in Saito-Sturmfels-Takayama
standardPairs = method()
standardPairs(MonomialIdeal, List) := (I,D) -> (
     R := ring I;
     X := generators R;
     S := {};
     k := coefficientRing R;
     scan(D, L -> ( 
     	       Y := X;
     	       m := vars R;
	       Lset := set L;
	       Y = select(Y, r -> not Lset#?r);
     	       m = substitute(m, apply(L, r -> r => 1));
	       -- using monoid to create ring to avoid 
	       -- changing global ring.
     	       A := k (monoid [Y]);
     	       phi := map(A, R, substitute(m, A));
     	       J := ideal mingens ideal phi generators I;
     	       Jsat := saturate(J, ideal vars A);
     	       if Jsat != J then (
     	  	    B := flatten entries super basis (
			 trim (Jsat / J));
		    psi := map(R, A, matrix{Y});
		    S = join(S, apply(B, b -> {psi(b), L}));
	       	    )));
     S)
Delta := (I) -> (
     X := generators ring I;
     d := #X - pdim cokernel generators I;
     select( apply(associatedPrimes I, J -> set X - set first entries generators J), Y -> #Y >= d ) / toList
     )

standardPairs MonomialIdeal := (I) -> standardPairs(I,Delta I)

--  LARGEST MONOMIAL IDEAL CONTAINED IN A GIVEN IDEAL  -----
monomialSubideal = method();				    -- needs a new name?
monomialSubideal Ideal := (I) -> (
     t := local t;
     R := ring I;
     X := generators R;
     k := coefficientRing R;
     S := k( monoid [t, X, MonomialOrder => Eliminate 1]);
     J := substitute(I, S);
     scan(#X, i -> (
	       w := {1} | toList(i:0) | {1} | toList(#X-i-1:0);
	       J = ideal homogenize(generators gb J, (generators S)#0, w);
	       J = saturate(J, (generators S)#0);
	       J = ideal selectInSubring(1, generators gb J);
	       ));
     monomialIdeal substitute(J, R)
     )

-- Local Variables:
-- compile-command: "make -C $M2BUILDDIR/Macaulay2/m2 "
-- End:
