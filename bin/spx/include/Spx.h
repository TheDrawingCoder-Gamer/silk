// Generated by Haxe 4.1.5
#ifndef INCLUDED_Spx
#define INCLUDED_Spx

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS0(Spx)



class HXCPP_CLASS_ATTRIBUTES Spx_obj : public ::hx::Object
{
	public:
		typedef ::hx::Object super;
		typedef Spx_obj OBJ_;
		Spx_obj();

	public:
		enum { _hx_ClassId = 0x7ee3a1af };

		void __construct();
		inline void *operator new(size_t inSize, bool inContainer=false,const char *inName="Spx")
			{ return ::hx::Object::operator new(inSize,inContainer,inName); }
		inline void *operator new(size_t inSize, int extra)
			{ return ::hx::Object::operator new(inSize+extra,false,"Spx"); }

		inline static ::hx::ObjectPtr< Spx_obj > __new() {
			::hx::ObjectPtr< Spx_obj > __this = new Spx_obj();
			__this->__construct();
			return __this;
		}

		inline static ::hx::ObjectPtr< Spx_obj > __alloc(::hx::Ctx *_hx_ctx) {
			Spx_obj *__this = (Spx_obj*)(::hx::Ctx::alloc(_hx_ctx, sizeof(Spx_obj), false, "Spx"));
			*(void **)__this = Spx_obj::_hx_vtable;
			return __this;
		}

		static void * _hx_vtable;
		static Dynamic __CreateEmpty();
		static Dynamic __Create(::hx::DynamicArray inArgs);
		//~Spx_obj();

		HX_DO_RTTI_ALL;
		static bool __GetStatic(const ::String &inString, Dynamic &outValue, ::hx::PropertyAccess inCallProp);
		static void __register();
		bool _hx_isInstanceOf(int inClassId);
		::String __ToString() const { return HX_("Spx",1b,5d,3f,00); }

		static void main();
		static ::Dynamic main_dyn();

};


#endif /* INCLUDED_Spx */ 
