/* Multiple versions of strspn.
   All versions must be listed in ifunc-impl-list.c.
   Copyright (C) 2017-2023 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <https://www.gnu.org/licenses/>.  */

/* Define multiple versions only for the definition in libc.  */
#if IS_IN (libc)
# define strspn __redirect_strspn
# include <string.h>
# undef strspn

# define SYMBOL_NAME strspn
# include "ifunc-sse4_2.h"

libc_ifunc_redirected (__redirect_strspn, strspn, IFUNC_SELECTOR ());

# ifdef SHARED
__hidden_ver1 (strspn, __GI_strspn, __redirect_strspn)
  __attribute__ ((visibility ("hidden"))) __attribute_copy__ (strspn);
# endif
#endif
