#include "hbclass.ch"
#include "inkey.ch"

function Main()

   local oEditor := HBSrcEdit():New( MemoRead( "editor.prg" ), 0, 0, MaxRow(), MaxCol(), .T. )

   oEditor:SetColor( "W/B,N/BG" )
   oEditor:Display()
   
   while ( nKey := Inkey( 0 ) ) != K_ESC
      oEditor:Edit( nKey )
      oEditor:Display()
   end

return nil   

CREATE CLASS HBSrcEdit FROM HBEditor

   METHOD Display()
   METHOD DisplayLine( nLine )
   METHOD LineColor( nLine ) INLINE If( nLine == ::nRow - ::nFirstRow, "N/BG", ::cColorSpec )

ENDCLASS

METHOD Display() CLASS HBSrcEdit

   local nRow, nCount

   DispBegin()
   nRow = ::nTop
   nCount = ::nNumRows
   while --nCount >= 0
      ::DisplayLine( nRow++ )
   end
   DispEnd()

return Self

METHOD DisplayLine( nLine ) CLASS HBSrcEdit

   local n, cLine, cToken := "", cColor := ""
   local cOperators := "<><=>=(),;.::=!=():),{})[]){}+=++---=*=/=%=^=="

   hb_DispOutAt( nLine, ::nLeft,;
                 SubStrPad( cLine := ::GetLine( ::nFirstRow + nLine ),;
                 ::nFirstCol, ::nNumCols ), ::LineColor( nLine ) )   

   n = 1
   while n < Len( cLine )
      while SubStr( cLine, n, 1 ) == " " .and. n < Len( cLine )
         n++
      end
      do case
         case SubStr( cLine, n, 1 ) == '"'
             cToken += '"' 
             while SubStr( cLine, ++n, 1 ) != '"' .and. n <= Len( cLine )
                cToken += SubStr( cLine, n, 1 )
             end
             cToken += '"'
             n++
   
         case SubStr( cLine, n, 1 ) $ cOperators
            while SubStr( cLine, n, 1 ) $ cOperators .and. n <= Len( cLine )
               cToken += SubStr( cLine, n++, 1 )
            end

         case ! SubStr( cLine, n, 1 ) $ " " + cOperators .and. n <= Len( cLine )
            while ! SubStr( cLine, n, 1 ) $ " " + cOperators .and. n <= Len( cLine )
               cToken += SubStr( cLine, n++, 1 )
            end

      endcase

      do case
         case Left( cToken, 1 ) == '"'
              cColor = "GR+"

         case Upper( cToken ) $ cOperators
              cColor = "R+"

         case Upper( cToken ) $ "FUNCTION,LOCAL,WHILE,FOR,NEXTRETURN,CREATE,FROM,METHOD,ENDCLASS"
              cColor = "G+"

         otherwise
              cColor = SubStr( ::LineColor( nLine ), 1, At( "/", ::LineColor( nLine ) ) - 1 )
      endcase 

       hb_DispOutAt( nLine, n - Len( cToken ) - ::nFirstCol, cToken,;
                     cColor + SubStr( ::LineColor( nLine ),;
                     At( "/", ::LineColor( nLine ) ) ) ) 

      cToken = ""
   end

return Self

static function SubStrPad( cText, nFrom, nLen )
   
return hb_UPadR( hb_USubStr( cText, nFrom, nLen ), nLen )
