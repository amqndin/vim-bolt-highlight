" Bolt — hybrid mcfunction + Python language syntax
" Builds on mcfunction highlighting with Bolt-specific extensions
" https://github.com/rubixninja314/vim-mcfunction

if exists("b:current_syntax")
        finish
endif

" === Load mcfunction base patterns ===
runtime syntax/mcfunction/mcfunction.vim
runtime syntax/mcfunction/highlight.vim

" b:current_syntax now set to 'mcfunction' by mcfunction.vim
" We'll override at end

" Chain entry for indented commands (Bolt YAML/Python blocks).
" mcCommand is contained, only reachable via nextgroup chain.
" This bridges indented lines that mcOptionalSlash (anchored to ^) misses.
syn match mcIndentPrefix /^\s\+/ nextgroup=mcCommand,boltImplicitExecute

" ============================================================
" Python Top-Level Keywords (line-start anchored)
" ============================================================
syn keyword boltDefKeyword       def                     skipwhite nextgroup=boltFunctionName
syn match   boltFunctionName    /\k\+/                  contained skipwhite nextgroup=boltParenRegion
syn region  boltParenRegion     matchgroup=boltParen start=/(/ end=/)/ contains=NONE                   contained

syn keyword boltClassKeyword    class                   skipwhite nextgroup=boltClassName
syn match   boltClassName       /\k\+/                  contained

syn keyword boltImportKeyword   from import
syn keyword boltControlKeyword  if else elif for while try except finally with
syn keyword boltControlKeyword  return yield raise pass break continue global nonlocal
syn keyword boltControlKeyword  not is and or

" NOTE: @defer has dedicated group below (later def wins for @defer)
syn match   boltDecorator       /^\s*@\k\+/

" ============================================================
" Python Function Calls
" ============================================================
syn match   boltFunctionCall    /\k\+\(\.\k\+\)*\ze\s*(/

" ============================================================
" Python Strings
" ============================================================
" Single-quoted strings with optional f-string prefix
syn region  boltString          start=+\%([fF]\)\='+ skip=+\\'+ end=+'+
syn region  boltString          start=+\%([fF]\)\="+ skip=+\\"+ end=+"+

" Raw strings
syn region  boltRawString       start=+\%([rR]\)'+ end=+'+
syn region  boltRawString       start=+\%([rR]\)"+ end=+"+

" Triple-quoted strings (f-string variants too)
" Defined after single/raw so last-defined region priority wins for ''' and """
syn region  boltTripleString    start=+\%([fF]\)\="""+ end=+"""+ contains=NONE
syn region  boltTripleSingle    start=+\%([fF]\)\='''+ end=+'''+ contains=NONE

" ============================================================
" Python Builtins
" ============================================================
syn keyword boltBuiltin         print len range int str float bool list dict set tuple
syn keyword boltBuiltin         getattr setattr hasattr type super
syn keyword boltBuiltin         zip map filter sorted reversed enumerate open
syn keyword boltBuiltin         min max sum any all abs round input next iter
syn keyword boltBuiltin         chr ord hex oct bin
syn keyword boltBuiltin         isinstance issubclass callable dir vars id hash
syn keyword boltBuiltin         object property staticmethod classmethod
syn keyword boltBuiltin         repr ascii format bytes bytearray memoryview frozenset

" ============================================================
" Python Constants
" ============================================================
syn keyword boltConstant        True False None true false

" ============================================================
" Python Numbers
" ============================================================
syn match   boltNumber          /\<[+-]\?\%(0[bBoOxX]\h\+\|\d\+\(\.\d*\)\?\%([eE][+-]\?\d\+\)\?\)/

" ============================================================
" Bolt Commands
" ============================================================
syn keyword mcCommand           raw contained skipwhite nextgroup=mcDoubleSpace,boltRawBody
syn match   boltRawBody         /.*/ contained

" ============================================================
" Bolt Keywords (macro, memo, defer, expand, etc)
" ============================================================
syn keyword boltBoltKeyword     macro memo
syn match   boltDeferDecorator  /^\s*@defer\>/
syn keyword boltBoltKeyword     require

" append/prepend/merge (resource modifiers)
syn keyword boltResourceModifier append prepend merge skipwhite nextgroup=boltResourceKeyword

" Nested resource keywords
syn keyword boltResourceKeyword function_tag block_tag item_tag entity_tag loot_table predicate

" command = "..." pattern (macro parameter)
syn match   boltParamEq         /^\s*command\s*=\s*/  skipwhite nextgroup=boltString

" ============================================================
" $(...) Interpolation
" ============================================================
syn region  boltInterpolation   matchgroup=boltInterpPunct start=/\$(/ end=/)/
syn region  boltInterpolation   matchgroup=boltInterpPunct start=/\${/ end=/}/

" ============================================================
" Relative Paths
" ============================================================
syn match   boltRelativePath    /\~\/\|\..\ze\/\|\.\/{[^}]*}\/\|\~\/{[^}]*}\//
syn match   boltResourceRef     /\~\/\w\+\|\.\.\?\/\w\+/
hi def link boltResourceRef     boltRelativePath

" ============================================================
" Implicit Execute at Line Start
" Both-highlighted: these also match Python keywords in some cases,
" but execute context (line start) prioritizes cleanly
" ============================================================
syn match   boltImplicitExecute /\s*\zs\%(as\|at\|unless\|positioned\|rotated\|anchored\|align\|facing\|run\|expand\)\>/ skipwhite nextgroup=mcSelectorExecute,mcExecuteCond,mcExecuteKeyword,mcCommand,mcExecuteStoreWhere,mcExecuteFacingEntityKeyword,mcExecuteAnchoredValue,mcExecuteAlignValue
hi def link boltImplicitExecute mcExecuteKeyword

" ============================================================
" Unpacking Operators
" ============================================================
syn match   boltUnpackingOp     /\*\{1,2}\ze\%([\[{("'a-zA-Z_]\)/

" ============================================================
" YAML Block Elements
" Indented key:value pairs and list items from Bolt's YAML blocks
" ============================================================
" NOTE: negative lookahead must stay in sync with boltControlKeyword above
syn match   boltYAMLKey         /^\s*\%(if\|else\|elif\|for\|while\|try\|except\|finally\|with\|return\|yield\|raise\|pass\|break\|continue\|global\|nonlocal\|not\|is\|and\|or\|def\|class\|from\|import\)\@![a-zA-Z_]\w*\ze\s*:/  skipwhite
syn match   boltYAMLListItem    /^\s*-\s\+/                skipwhite

" ============================================================
" Comments
" ============================================================
syn match   boltComment /^\s*#.*$/ contains=@Spell

" ============================================================
" Variable Assignment (top-level)
" ============================================================
syn match   boltAssignment      /^\s*\k\+\(\.\k\+\)*\s*=\ze[^=]/     skipwhite nextgroup=boltString,boltNumber,boltTripleString,boltRawString

" Placeholder for list/dict literals after assignment
" (covered by boltNumber, boltString, etc)

syn sync fromstart

" ============================================================
" Highlight Links
" ============================================================
runtime syntax/bolt/highlight.vim

let b:current_syntax = 'bolt'
