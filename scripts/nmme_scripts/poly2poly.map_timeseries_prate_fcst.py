#!/usr/bin/env python
# Process timeseries grid into mean areal timeseries for arbitrary polygons
# Depends on mapping file from poly2poly.py and associated scripts by K. Sampson, NCAR
# 
# Notes:  AWW: on yellowstone, needs 'module load netcdf4python'
#
# Author:    Naoki Mizukami, Feb 2014
# Modifications:
#   AWW Feb 2014, Documented code and adapted to work on BCSD5-NLDAS to HUC4 conversion
#   AWW Jan 2015, Adapted to ens. forc. generation
#                       writes out pcp, tmax, tmin, tmean, trange
#                       and write all out into one file (so has one fewer arg)
#          updated print statements to python 3 style, also raise statement
#   EAC Jul 2016, Mod. to work with new hru wgtnc format, which
#          uses i_index and j_index instead of latitude and longitude
#   AWW Jul 2015, flipped j_index, shifted to match 0 range start, and altered
#          various loop indices to be more intuitive; improved messaging
# =========================================================================

import sys
sys.path.append("/d6/nijssen/anaconda/pkgs/numpy-1.9.2-py27_0/lib/python2.7/site-packages/")
sys.path.append("/d6/nijssen/anaconda/lib/python2.7/site-packages/")

import os
import time 
import getopt
import numpy as np
import netCDF4 as nc4

############################################ 
#              Class                       #
############################################
class wgtnc:
    """object of basin netCDF including hru and areal weight/i_index/j_index of others polygons  """
    def __init__(self,nc):
        """Initialization """
        self.nc=nc

    def getWgtHru(self,hru):
        """For given hru id, get weight of the intersected polygons and associated 
           i_index, j_index"""
        print(hru)
        wgtAll = getNetCDFData(self.nc, 'weight')
        hruAll = getNetCDFData(self.nc, 'IDmask') 
        i_indexAll = getNetCDFData(self.nc, 'i_index') # EAC get i_index --- LON direction
        j_indexAll = getNetCDFData(self.nc, 'j_index') # EAC get j_index --- LAT direction 
        hruList = self.getHruID() # EAC-get hru id list
        Index = [i for i, x in enumerate(hruAll) if x == hru] # EAC-get index corresponding to hru

        self.wgt = list(wgtAll[Index]) #Get wgt list for hru
        print("len wgt = %d " % len(self.wgt))
        self.i_index = list(i_indexAll[Index]) #Get i_index list for hru
        self.j_index = list(j_indexAll[Index]) #Get j_index list for hru
        
        return (self.wgt, self.i_index, self.j_index)

    def getHruID(self):
        """ get hru ID list of basin"""
        self.hruid = list(getNetCDFData(self.nc, 'polyid')) # EAC get polyid for hru list 
        if type(self.hruid) != int:                         # NM: to check hruid list type 
          self.hruid = map(int, self.hruid)                 # NM: to change string to int if not int
        return self.hruid

########################################################################
#                                Modules                               #
########################################################################

def getNetCDFData(fn, varname):
    """Read <varname> variables from NetCDF <fn> """
    f = nc4.Dataset(fn,'r')
    data = f.variables[varname][:]
    f.close()
    return data

def getNetCDFDim(fn, varname):
    """ Get dimension name used in <varname> from NetCDF <fn> """ 
    f = nc4.Dataset(fn,'r')
    dim = f.variables[varname].dimensions

    data = dict()
    for dimname in dim:
        data[dimname]=f.variables[dimname][:]
    f.close()
    return data 

# custom write function to handle ensemble forcing grid vars pcp, t_mean and t_range
def writeNetCDFData(fn, prate, times, hrus):
    """ Write <vars>[time,hru] array in netCDF4 file,<fn> and variable of <varname> """
    ncfile = nc4.Dataset(fn,'w',format='NETCDF4')
  
    # Data should be 2D [time x hru]
    dim2size = prate.shape[1]
   
    dim_1 = ncfile.createDimension('time', None)  # time axis - record dimension
    dim_2 = ncfile.createDimension('hru', dim2size)  # hru axis
    max_strlen = 12  # EAC
    dim_3 = ncfile.createDimension('strlen', max_strlen) # string length for hrus EAC adde
  
    # Define dimensions variable to hold the var
    t = ncfile.createVariable('time', 'i4', ('time', ))
    hru = ncfile.createVariable('hru', 'S1', ('hru', 'strlen'))   # edited EAC
  
    # Define 2D variables to hold the data
   # AWW:  changed variable name to match use for cfsv2
    map = ncfile.createVariable('prate','f4',('time','hru',))  
   # tavg_2m = ncfile.createVariable('tmp_2m','f4',('time','hru',))  

   
    # Populate netcdf file variables
    t[:]      = times   # NM added
    hru[:]    = nc4.stringtochar(np.asarray(hrus, dtype='S{}'.format(max_strlen))) # EAC
    map[:,:]  = prate   # for mean area precip (map), etc.
   # tavg_2m[:,:] = tmp_2m
  
    # Attributes (should take more from input netcdf)
    # set time axis
    t.time_origin = '1970-JAN-01 00:00:00'
    t.title = 'Time'
    t.long_name = 'Time axis'
    t.units = 'seconds since 1970-01-01 00:00:00'
    t.calendar = 'Gregorian'
    t.axis = 'T'
    # set hru axis
    hru.title = 'HRU ID'
    hru.long_name = 'HRU axis'
    hru.axis = 'X'
  
    # set variable attributes

    # AW - commented out vars above and used temp_2m
    map.associate = 'time hru'
    map.units = 'kg/m^2/s'
    map.setMissing = '1.e+20'
    map.axis = 'TX'
    
    #tavg_2m.associate = 'time hru'  
    #tavg_2m.units = 'degrees C'
    #tavg_2m.setMissing = '1.e+20'
    #tavg_2m.axis = 'TX'
  
    # Write basic global attribute
    ncfile.history = 'Created ' + time.ctime(time.time())
    ncfile.source = os.path.dirname(os.path.abspath(__file__))+__file__[1:]
    
    ncfile.close()
  
def compAvgVal(nc_wgt,nc_in,varname):
    """Compute areal weighted avg value of <varname> in <nc_in> for each hru based on hru's weight in <nc_wgt>""" 
    wgt    = wgtnc(nc_wgt)  # instantiate current wgtnc object -- creates object
    hruIDs = wgt.getHruID() # get hruID list
  
    dataVal = getNetCDFData(nc_in,varname)     # Get data value 
    timeVal = getNetCDFData(nc_in,'fcst_time')   # could speed this up by not importing this after the first time

    dim1size = dataVal.shape[0]  # time dimension
    gridrows = dataVal.shape[1]  # grid rows dim (y)
    gridcols = dataVal.shape[2]  # grid cols dim (x)
    #print("times %d rows %d cols %d" % (dim1size, gridrows, gridcols))

    # AW: next two vars are not needed, but can be used during debugging (leave in)
    #latVal = getNetCDFData(nc_in,'latitude')   # GRID READ so [0,0] is LL corner
    #lonVal  = getNetCDFData(nc_in,'longitude')
  
    # Initialize data storage for weighted average time series for hru
    for h in range(len(hruIDs)):

        print("h = %d hruIDs[h] = %s " % (h, hruIDs[h]))        
        # Get list of wgt, i_index, and j_index for corresponding hru
        (wgtval, i_index, j_index)=wgt.getWgtHru(hruIDs[h]) # EAC indices instead of lat lon

        ncells = len(wgtval)  # useful limit for several loops in this block
        print("ncells = %d" % ncells)

        # AW: need to (a) subtract 1 since grids are referenced to [0,0] and (b) flip j-index 
        # so that's:  j_index = (gridcols - j_index + 1) - 1 = gridcols - j_index; SB: i_index -1
        for c in range(0,ncells):
            j_index[c] = gridrows - j_index[c]
            i_index[c] = i_index[c] - 1

        # ---- Calculate time series of weighted value for input polygon  ----
  
        # first, reset weights for the missing cells to zero
        sumweights = 0
        numvoid    = 0
        validcell  = 0
        for c in range(0,ncells):    # loop through cells(ie, c) assigned to this HRU
            validcell = validcell + 1
            yj = j_index[c] # instead of lat EAC -- y-index from UL corner (increments N->S)
            xi = i_index[c] # instead of lon EAC -- x-index from UL corner (increments W->E)
            # check if first timestep for cell is missing
            if dataVal[1,yj,xi] > 1.e+19:
                wgtval[c] = 0
                numvoid = numvoid + 1
            sumweights = sumweights + wgtval[c]

        print("------------")
        print(" var %s hru %d %s: num voids = %d out of %d" % (varname, h, hruIDs[h], numvoid,validcell))
        print(" new sum of weights is %f" % sumweights)
  
        if sumweights > 0: 
            # renormalize weights (won't work if all cells void)
            print(" normalizing...")
            for c in range(0,ncells):
                wgtval[c] = (wgtval[c]/sumweights)
  
        # now apply each wgt to cell data for all times
        for c in range(0,ncells):
            yj = j_index[c]
            xi = i_index[c]

            # weight values
            Val1=wgtval[c]*dataVal[:,yj,xi].reshape(-1,1)  # this is a vector with time
  
            if c == 0:
                oriVal = Val1*0   # start with zero vector, won't affect sum
  
            # weight is above zero, add data from new cell
            if wgtval[c]>0:
                oriVal=np.concatenate((oriVal, Val1), axis=1)
 
        Val2=oriVal.sum(axis=1).reshape(-1,1)   # sum up weighted HRU cell
        del oriVal 

        # block for setting voids in HRUs with no good data
        if numvoid==validcell:
            print( "ALL cells (%d of %d) in hru %d are void, outputting voids" % (numvoid,validcell,h))
  
            # assign voids (maybe not needed if using Val2 from above)
            for tm in range(len(Val2)): 
                Val2[tm] = 1.e+20
  
        # now store time vector of HRU results
        if h == 0:
            wgtedVal = Val2
        else:
            wgtedVal=np.concatenate((wgtedVal, Val2), axis=1)
  
    return timeVal,hruIDs,wgtedVal

############################################
#                Main                      #
############################################
use = '''
Usage: %s -[h] <weight_netCDF> <input_netCDF> <output_netCDF>
        -h  help
'''
if __name__ == '__main__':

    def usage():
        sys.stderr.write(use % sys.argv[0])
        sys.exit(1)
    try:
        (opts, args) = getopt.getopt(sys.argv[1:], 'h')
    except getopt.error:
        usage()

    verbose = False
    grid_info = False
    proj_info = True
    for (opt,val) in opts:
        if opt == '-h':
            usage()
        elif opt == '-v':
            verbose = True
        else:
            #raise OptionError, opt
            raise OptionError(opt)
            usage()

    if len(args) == 3:
        nc_wgt  = args[0]
        nc_in   = args[1]  
        nc_out  = args[2]

        # hardwired to ensemble forcing grid formats     
        times,hrus,MAP=compAvgVal(nc_wgt,nc_in,'prate')
	writeNetCDFData(nc_out, MAP, times, hrus)
       # times,hrus,T2M=compAvgVal(nc_wgt,nc_in,'tmp_2m')
       # writeNetCDFData(nc_out, T2M, times, hrus)      
      
    else:
        usage()

