module Latex2MathML.Utils.Definitions where

import Data.Set (fromList,Set)

data Token = Command String |
    MyStr String |
    Sub |
    Sup |
    Operator String |
    MyNum String |
    End |
    BodyBegin |
    BodyEnd |
    Error
    deriving (Show,Eq)

data ASTModel = BodylessCommand String |
   InlineCommand String [Token] [[Token]] |
   ComplexCommand String [Token] [Token] |
   ASTOperator String |
   ASTSub [Token] |
   ASTSup [Token] |
   Variable Char |
   MN String

operators :: String
operators = "+-*/=!():<>|[]&\n,.'$"

commands :: Set String
commands = fromList ["hat", "grave", "bar", "acute", "mathring", "check", "dot", "vec", "breve", "tilde", "ddot", "widehat", "widetilde", "alpha", "A", "Alpha", "beta", "B", "Beta", "Gamma", "gamma", "Delta", "delta", "epsilon", "varepsilon", "E", "zeta", "Z", "eta", "H", "Theta", "theta", "vartheta", "iota", "I", "kappa", "varkappa", "K", "lambda", "Lambda", "mu", "M", "nu", "N", "Xi", "xi", "O", "o", "Pi", "pi", "varpi", "rho", "varrho", "P", "sigma", "Sigma", "varsigma", "tau", "T", "Upsilon", "upsilon", "Phi", "phi", "varphi", "chi", "X", "Psi", "psi", "Omega", "omega", "omicron", "prod", "sum", "lim", "int", "parallel", "nparallel", "leq", "geq", "doteq", "asymp", "bowtie", "ll", "gg", "equiv", "vdash", "dashv", "subset", "supset", "approx", "in", "ni", "subseteq", "supseteq", "cong", "smile", "frown", "nsubseteq", "nsupseteq", "simeq", "models", "notin", "sqsubset", "sqsupset", "sim", "perp", "mid", "sqsubseteq", "sqsupseteq", "propto", "prec", "succ", "preceq", "succeq", "neq", "sphericalangle", "measuredangle", "pm", "cap", "diamond", "oplus", "mp", "cup", "bigtriangleup", "ominus", "times", "uplus", "bigtriangledown", "otimes", "div", "sqcap", "triangleleft", "oslash", "ast", "sqcup", "triangleright", "odot", "star", "vee", "bigcirc", "circ", "dagger", "wedge", "bullet", "setminus", "ddagger", "cdot", "wr", "amalg", "exists", "rightarrow", "to", "nexists", "leftarrow", "gets", "forall", "mapsto", "neg", "implies", "subset", "Rightarrow", "supset", "leftrightarrow", "in", "iff", "notin", "Leftrightarrow", "ni", "top", "land", "bot", "lor", "emptyset", "varnothing", "backslash", "langle", "rangle", "uparrow", "Uparrow", "lceil", "rceil", "downarrow", "Downarrow", "lfloor", "rfloor", "sin", "arcsin", "sinh", "sec", "cos", "arccos", "cosh", "csc", "tan", "arctan", "tanh", "cot", "arccot", "coth", "partial", "imath", "Re", "nabla", "aleph", "eth", "jmath", "Im", "Box", "beth", "hbar", "ell", "wp", "infty", "gimel","frac","sqrt","binom","quad","cfrac","ldots","mathrm","cdots","vdots","exp","ddots","left(","right)","left[","right]","left{","right}","text"]

complex :: Set String
complex = fromList ["matrix","table","array"]