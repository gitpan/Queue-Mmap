#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"
#include "queue_internal.h"

MODULE = Queue::Mmap		PACKAGE = Queue::Mmap

SV *
queue_new(fn,q,r)
	SV *fn
	int q
	int r
  INIT:
	struct object * obj;
	SV * obj_pnt, * ret;
	void *strp;
	int strl;
	STRLEN strlo;
	char* tmp;
  CODE:
	strp = (void *)SvPV(fn, strlo);
	strl = (int)strlo;
	tmp =(char*)malloc(strl+1);
	memcpy(tmp,strp,strl);
	tmp[strl] = 0;

	obj = new_queue();
	calc_queue(obj,tmp,q,r);
	init_queue(obj);
	
	free(tmp);

	/* Create integer which is pointer to cache object */
	obj_pnt = newSViv(PTR2IV(obj));

	/* Create reference to integer value. This will be the object */
	ret = newRV_noinc((SV *)obj_pnt);

	RETVAL = ret;
  OUTPUT:
	RETVAL

SV *
queue_pop(que)
	SV*  que
INIT:
	struct object * obj;
	SV* value;

	if (!SvROK(que)) {
	  croak("Object not reference");
	  XSRETURN_UNDEF;
	}
	que = SvRV(que);
	if (!SvIOKp(que)) {
	  croak("Object not initiliased correctly");
	  XSRETURN_UNDEF;
	}
	obj = INT2PTR(struct object*, SvIV(que));
	if (!obj) {
	  croak("Object not created correctly");
	  XSRETURN_UNDEF;
	}
CODE:
	if((value = pop_queue(obj))){
	  RETVAL = value;
	}else{
		XSRETURN_UNDEF;
	}
OUTPUT:
	RETVAL

SV *
queue_top(que)
	SV*  que
INIT:
	struct object * obj;
	SV* value;

	if (!SvROK(que)) {
	  croak("Object not reference");
	  XSRETURN_UNDEF;
	}
	que = SvRV(que);
	if (!SvIOKp(que)) {
	  croak("Object not initiliased correctly");
	  XSRETURN_UNDEF;
	}
	obj = INT2PTR(struct object*, SvIV(que));
	if (!obj) {
	  croak("Object not created correctly");
	  XSRETURN_UNDEF;
	}
CODE:
	if((value = top_queue(obj))){
	  RETVAL = value;
	}else{
		XSRETURN_UNDEF;
	}
OUTPUT:
	RETVAL
	
int
queue_drop(que)
	SV*  que
INIT:
	struct object * obj;
	SV* value;

	if (!SvROK(que)) {
	  croak("Object not reference");
	  XSRETURN_UNDEF;
	}
	que = SvRV(que);
	if (!SvIOKp(que)) {
	  croak("Object not initiliased correctly");
	  XSRETURN_UNDEF;
	}
	obj = INT2PTR(struct object*, SvIV(que));
	if (!obj) {
	  croak("Object not created correctly");
	  XSRETURN_UNDEF;
	}
CODE:
	drop_queue(obj);
	RETVAL = 1;
OUTPUT:
	RETVAL

int
queue_push(que,value)
	SV * que;
	SV * value;
  INIT:
	struct object * obj;
	void *strp;
	int strl;
	STRLEN strlo;

	if (!SvROK(que)) {
	  croak("Object not reference");
	  XSRETURN_UNDEF;
	}
	que = SvRV(que);
	if (!SvIOKp(que)) {
	  croak("Object not initiliased correctly");
	  XSRETURN_UNDEF;
	}
	obj = INT2PTR(struct object*, SvIV(que));
	if (!obj) {
	  croak("Object not created correctly");
	  XSRETURN_UNDEF;
	}
CODE:
	strp = (void *)SvPV(value, strlo);
	strl = (int)strlo;
	
	if(strl > obj->rec_len * (obj->que_len - 1)){
	  XSRETURN_UNDEF;
	}

	push_queue(obj,strp,strl);
	RETVAL = 1;
OUTPUT:
	RETVAL


void
queue_free(que)
	SV*  que
INIT:
	struct object * obj;

	if (!SvROK(que)) {
	  croak("Object not reference");
	  XSRETURN_UNDEF;
	}
	que = SvRV(que);
	if (!SvIOKp(que)) {
	  croak("Object not initiliased correctly");
	  XSRETURN_UNDEF;
	}
	obj = INT2PTR(struct object*, SvIV(que));
	if (!obj) {
	  croak("Object not created correctly");
	  XSRETURN_UNDEF;
	}
CODE:
	free_queue(obj);

void
queue_stat(que)
	SV*  que
INIT:
	struct object * obj;

	if (!SvROK(que)) {
	  croak("Object not reference");
	  XSRETURN_UNDEF;
	}
	que = SvRV(que);
	if (!SvIOKp(que)) {
	  croak("Object not initiliased correctly");
	  XSRETURN_UNDEF;
	}
	obj = INT2PTR(struct object*, SvIV(que));
	if (!obj) {
	  croak("Object not created correctly");
	  XSRETURN_UNDEF;
	}
PPCODE:
	XPUSHs(sv_2mortal(newSVnv(obj->q->top)));
	XPUSHs(sv_2mortal(newSVnv(obj->q->bottom)));
	XPUSHs(sv_2mortal(newSVnv(obj->que_len)));
	XPUSHs(sv_2mortal(newSVnv(obj->rec_len)));

int
queue_len(que)
	SV*  que
INIT:
	struct object * obj;
	int t,b;

	if (!SvROK(que)) {
	  croak("Object not reference");
	  XSRETURN_UNDEF;
	}
	que = SvRV(que);
	if (!SvIOKp(que)) {
	  croak("Object not initiliased correctly");
	  XSRETURN_UNDEF;
	}
	obj = INT2PTR(struct object*, SvIV(que));
	if (!obj) {
	  croak("Object not created correctly");
	  XSRETURN_UNDEF;
	}
CODE:
	t = obj->q->top;
	b = obj->q->bottom;
	if(t<=b){
	  RETVAL = b - t;
	}else{
	  RETVAL = obj->que_len + b - t;
	}
OUTPUT:
	RETVAL


