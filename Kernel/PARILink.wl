Print["Loading PARILink..."];

ClearAll["PARILink`*"]

BeginPackage["PARILink`"]

(* Exported symbols added here with SymbolName::usage *)

PariKernelVersion::usage = "pariKernelVersion[] returns the version of the PARI/GP kernel."
PariToString::usage = "PariToString[obj] converts a PARI object to a string."
CreatePariObjectFromType::usage = "CreatePariObjectFromType[type, n] creates a PARI object of the specified type and size."
CreatePariObjectFromInteger::usage = "CreatePariObjectFromInteger[n] converts an integer n to a PARI object."
CreatePariObjectFromReal::usage = "CreatePariObjectFromReal[r] converts a real number r to a PARI object."
PariFractionalPart::usage = "PariFractionalPart[obj] returns the fractional part of obj."
PariDivide::usage = "PariDivide[a, b] returns a/b."

Begin["`Private`"]

(* Implementation of the package *)

(* core types *)
tINT = 1;
tREAL = 2;
tINTMOD = 3;
tFRAC = 4;
tFFELT = 5;
tCOMPLEX = 6;
tPADIC = 7;
tQUAD = 8;
tPOLMOD = 9;
tPOL = 10;
tSER = 11;
tRFRAC = 13;
tQFB = 15;
tVEC = 17;
tCOL = 18;
tMAT = 19;
tLIST = 20;
tSTR = 21;
tVECSMALL = 22;
tCLOSURE = 23;
tERROR = 24;
tINFINITY = 25;


this = DirectoryName[$InputFileName];
lib = FileNameJoin[{ParentDirectory[this], "Libraries", $SystemID, "libpari-gmp.dylib"}];

(* load and start PARI *)
pariInit = ForeignFunctionLoad[lib, "pari_init", {"CSizeT", "CUnsignedLong"} -> "Void"];
pariInit[8000000, 500000];

(* type shortcuts *)
charPtr = "RawPointer"::["UnsignedInteger8"];

(* PARI/GP kernel version *)
parikernelversion = ForeignFunctionLoad[lib, "pari_kernel_version", {} -> charPtr]
PariKernelVersion[] := RawMemoryImport[parikernelversion[], "String"]

(* Convert PARI object to string *)
GENtostr = ForeignFunctionLoad[lib, "GENtostr", {"OpaqueRawPointer"} -> charPtr]
PariToString[obj_] := RawMemoryImport[GENtostr[obj], "String"]

(* GEN cgetg(long l, long t) l specifies the number of longwords to be allocated to the object,
and t is the type of the object, in symbolic form*)

cgetg = ForeignFunctionLoad[lib, "cgetg", {"CLong", "CLong"} -> "OpaqueRawPointer"]
CreatePariObjectFromType[type_, n_] := cgetg[n, type]

(* GEN mkvecn(long n, ...) returns the t_VEC whose n coefficients (GEN) follow. *)
mkvecn = ForeignFunctionLoad[lib, "mkvecn", {"CLong", "OpaqueRawPointer"} -> "OpaqueRawPointer"]


(* Convert integer to Pari object *)
stoi = ForeignFunctionLoad[lib, "stoi", {"CLong"} -> "OpaqueRawPointer"]
CreatePariObjectFromInteger[n_Integer] := stoi[n]

uu32toi = ForeignFunctionLoad[lib, "uu32toi", {"CUnsignedLong", "CUnsignedLong"} -> "OpaqueRawPointer"]

(* Convert real to Pari object *)
dbltor = ForeignFunctionLoad[lib, "dbltor", {"CDouble"} -> "OpaqueRawPointer"]
CreatePariObjectFromReal[r_Real] := dbltor[r]

(* Get the fractional part from obj *)
gfrac = ForeignFunctionLoad[lib, "gfrac", {"OpaqueRawPointer"} -> "OpaqueRawPointer"]
PariFractionalPart[obj_] := gfrac[obj]

gdiv = ForeignFunctionLoad[lib, "gdiv", {"OpaqueRawPointer", "OpaqueRawPointer"} -> "OpaqueRawPointer"]
PariDivide[a_, b_] := gdiv[a, b]


(* 
    Elliptic curves 

GEN ellinit(GEN E, GEN D, long prec), returns an ell structure, associated to the elliptic
curve E : either an ell5, a pair [a4, a6] or a t_STR in Cremona’s notation, e.g. "11a1". The
optional D (NULL to omit) describes the domain over which the curve is defined.
*)

ellinit = ForeignFunctionLoad[lib, "ellinit", {"OpaqueRawPointer", "OpaqueRawPointer", "CLong"} -> "OpaqueRawPointer"]
CreatePariEllipticCurve[E_, prec_] := ellinit[E, OpaqueRawPointer[0], prec]

End[]

EndPackage[]