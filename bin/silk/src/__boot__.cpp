// Generated by Haxe 4.1.5
#include <hxcpp.h>

#ifndef INCLUDED_haxe_SysTools
#include <haxe/SysTools.h>
#endif
#ifndef INCLUDED_haxe_iterators_ArrayIterator
#include <haxe/iterators/ArrayIterator.h>
#endif
#ifndef INCLUDED_Sys
#include <Sys.h>
#endif
#ifndef INCLUDED_StringTools
#include <StringTools.h>
#endif
#ifndef INCLUDED_StringBuf
#include <StringBuf.h>
#endif
#ifndef INCLUDED_Std
#include <Std.h>
#endif
#ifndef INCLUDED_Silk
#include <Silk.h>
#endif
#ifndef INCLUDED_EReg
#include <EReg.h>
#endif

void __files__boot();

void __boot_all()
{
__files__boot();
::hx::RegisterResources( ::hx::GetResources() );
::haxe::SysTools_obj::__register();
::haxe::iterators::ArrayIterator_obj::__register();
::Sys_obj::__register();
::StringTools_obj::__register();
::StringBuf_obj::__register();
::Std_obj::__register();
::Silk_obj::__register();
::EReg_obj::__register();
::haxe::SysTools_obj::__boot();
}

