/****************************************************************************
Copyright (c) 2011-2013,WebJet Business Division,CYOU

http://www.genesis-3d.com.cn

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
#ifndef __PARTICLE_SPHERESURFACE_EMITTER_H__
#define __PARTICLE_SPHERESURFACE_EMITTER_H__
#include "particles/particle_fwd_decl.h"
#include "particles/particleemitter.h"

namespace Particles
{
	class SphereSurfaceEmitter: public ParticleEmitter
	{
		__DeclareSubClass( SphereSurfaceEmitter, ParticleEmitter);
	public:
		static const Math::scalar DEFAULT_RADIUS;

	public:

		SphereSurfaceEmitter();
		virtual ~SphereSurfaceEmitter(){};

		Math::scalar GetRadius(void);
		void SetRadius(Math::scalar radius);

		Math::scalar GetSphereHem();

		Math::scalar GetSphereSlice();

		virtual void _initParticlePosition(Particle* particle);

		virtual void _initParticleVelocity(Particle* particle);

	public:
		virtual Math::MinMaxCurve* getMinMaxCurve(ParticleCurveType pct);
		virtual void _switchParticleType(bool _isMobile);
	protected:

		Math::MinMaxCurve			mRadiusCurve;
		Math::MinMaxCurve			mHemCurve;
		Math::MinMaxCurve			mSliceCurve;


	public:
		// @ISerialization::GetVersion. when change storage, must add SerializeSVersion count
		virtual Serialization::SVersion GetVersion() const;

		// @ISerialization::Load 
		virtual void Load( Serialization::SVersion ver, Serialization::SerializeReader* pReader, const Serialization::SerializationArgs* args );

		// @ISerialization::Save
		virtual void Save( Serialization::SerializeWriter* pWriter ) const;

		/**
		@ copy from parent particle
		*/
		virtual void CopyFrom( const ParticleEmitterPtr& emitter );
	};
}
#endif

