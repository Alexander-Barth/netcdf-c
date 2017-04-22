/*! \file netcdf_filter.h
 *
 * Main header file for filter functionality.
 *
 * Copyright 2010 University Corporation for Atmospheric
 * Research/Unidata. See COPYRIGHT file for more info.
 *
 * See \ref copyright file for more info.
 *
 */

#ifndef NETCDF_FILTER_H
#define NETCDF_FILTER_H 1

#include <netcdf.h>

#if defined(__cplusplus)
extern "C" {
#endif

EXTERNL int nc_def_var_filter(int ncid, int varid, unsigned int id, size_t nparams, const unsigned int* parms);


#if defined(__cplusplus)
}
#endif

#endif /* NETCDF_FILTER_H */
