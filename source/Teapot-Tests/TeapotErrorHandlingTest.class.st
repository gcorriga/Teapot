Class {
	#name : 'TeapotErrorHandlingTest',
	#superclass : 'TestCase',
	#instVars : [
		'server'
	],
	#category : 'Teapot-Tests',
	#package : 'Teapot-Tests'
}

{ #category : 'private' }
TeapotErrorHandlingTest >> handleError: ex request: req [
	self assert: (ex isKindOf: Exception).
	self assert: (req isKindOf: TeaRequest).
	^ ZnResponse ok: (ZnStringEntity text: 'outofbounds/domainerror handled')
]

{ #category : 'running' }
TeapotErrorHandlingTest >> setUp [
	server := Teapot on
		GET: '/zerodiv' -> [ 1 / 0 ];
		GET: '/sub' -> [ #() at: 123 ];			
		GET: '/domain' -> [ -2 sqrt ];
		GET: '/nonbool' -> [ NotYetImplemented signal ];
		GET: '/keynotfound' -> [ KeyNotFound signal ];
		exception: ZeroDivide -> [ :ex :req | 'zerodiv handled' ];
		exception: SubscriptOutOfBounds, DomainError -> (Send message: #handleError:request: to: self);
		exception: NotYetImplemented -> (ZnResponse ok: (ZnStringEntity text: 'nonbool handled'));
		exception: KeyNotFound -> 42;
		output: [ :resp :req | ZnResponse ok: (ZnStringEntity text: resp body printStringRoman) ];
		start		
]

{ #category : 'running' }
TeapotErrorHandlingTest >> tearDown [
	server stop
]

{ #category : 'tests' }
TeapotErrorHandlingTest >> testHandlesExceptionSet [
	self assert: (TeaTestClient httpGetString: '/sub') equals: 'outofbounds/domainerror handled'.	
	self assert: (TeaTestClient httpGetString: '/domain') equals: 'outofbounds/domainerror handled'.		
]

{ #category : 'tests' }
TeapotErrorHandlingTest >> testHandlesOneException [
	self assert: (TeaTestClient httpGetString: '/zerodiv') equals: 'zerodiv handled'.	
]

{ #category : 'tests' }
TeapotErrorHandlingTest >> testTransformingErroHandlerResponse [
	self assert: (TeaTestClient httpGetString: '/keynotfound') equals: 'XLII'.
]

{ #category : 'tests' }
TeapotErrorHandlingTest >> testValueAsExceptionHandler [
	self assert: (TeaTestClient httpGetString: '/nonbool') equals: 'nonbool handled'.	
]
