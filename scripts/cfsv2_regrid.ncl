; NOTE: ncl only works on hydro-c1 (as far as I can tell...)

;*************************************************************
; cfsv2regird.ncl
;
; Concepts illustrated:
;   - Reading a variable off a file and updating its meta data
;   - Interpolating from a global GAUSSIAN grid to a lower resolution
;   - Creating a netCDF file
;
; Usage    : 'in_file=$File' 'var_in=$Var' 'out_file=$NCDir/$Var/$Year/$File:t:r.nc' cfsv2_regrid.ncl
; TEST
;	in_file = "~/s2s/cfsv2/netcdfs/tmp2m.1999010100.nc"
;	var_in = "tmp2m_f"
;	out_file = "~/s2s/cfsv2/netcdfs/tmp2m.test.nc"
;
;*************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

begin
;*************************************************************
; read 
;*************************************************************
   f = addfile(in_file, "r") ;
   
   if ( var_in .eq. "tmp2m" ) then
   		x = f->TMP_2maboveground
   		x@units = "K"
   else if ( var_in .eq. "prate" ) then
   		x = f->PRATE_surface
   		x@units = "kg/m^2/s"
   else
   		print( "... variable not found (eg. tmp2m_f or prate_f)")
   		exit
   	end if
   	end if

  ;printVarSummary(x)
  ;printMinMax(x, True)
;*************************************************************
; perform conservative remapping to two different grid resolutions
;*************************************************************
   opt = False

   NLAT05x05  =  360      ; RES   = "0.5x.05"    
   MLON05x05  =  720                             
   LAT05x05   = latGlobeFo(NLAT05x05, "LAT", "latitude" , "degrees_north")
   LON05x05   = lonGlobeFo(MLON05x05, "LON", "longitude", "degrees_east" )  ; 1.0E->359.0E
   X05x05     = area_conserve_remap_Wrap (x&longitude, x&latitude, x ,LON05x05, LAT05x05, opt)

   ;printVarSummary(X05x05)
   ;printMinMax(X05x05, True)
;************************************************
; Create netCDF
; Create a 'time' dimension 
;************************************************
globeAtt              = 1
globeAtt@title        = "tmp_2m: T126 interpolated to a 0.5x0.5 degree grid"    
globeAtt@source_file  = in_file
globeAtt@creation_date= systemfunc ("date")
     
system ("/bin/rm -f " +  out_file)    ; remove any pre-exist file 
           
ncdf   = addfile(out_file,"c")     
fileattdef( ncdf, globeAtt )        ; create the global [file] attributes

filedimdef(ncdf,"time",-1,True)     ; make time and UNLIMITED dimension      

ncdf->PRC = X05x05

end
