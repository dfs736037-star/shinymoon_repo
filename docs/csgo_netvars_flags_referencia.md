# Referência de Netvars, Props e Flags do CS:GO / Source Engine

> Documento de referência com nomes comuns de **netvars**, **props** e **flags** associados ao CS:GO / Source Engine.  
> A lista é voltada para estudo, análise de demos, modding legítimo, SourceMod, documentação técnica e compreensão da estrutura do jogo.  
> **Não inclui offsets, assinaturas, bypasses, leitura de memória ou instruções para cheat.**

---

## Observação importante

Uma lista **100% completa** depende da versão/build do CS:GO/CS2 e do dump utilizado.  
As netvars/props podem mudar entre atualizações do jogo.

O termo que originou esta lista foi:

```cpp
m_flSimulationTime
```

Ele é uma propriedade usada para indicar o tempo de simulação de uma entidade, bastante conhecida em contextos de Source Engine, demos, netvars e análise de entidades.

---

# 1. Principais netvars / props do CS:GO

## 1.1 Base Entity / Entidade geral

```cpp
m_flSimulationTime
m_flAnimTime
m_vecOrigin
m_angRotation
m_nModelIndex
m_fEffects
m_nRenderMode
m_nRenderFX
m_clrRender
m_iTeamNum
m_iPendingTeamNum
m_Collision
m_CollisionGroup
m_usSolidFlags
m_nSolidType
m_bSimulatedEveryTick
m_bAnimatedEveryTick
m_bAlternateSorting
m_hOwnerEntity
m_hEffectEntity
m_iParentAttachment
m_vecMins
m_vecMaxs
```

---

## 1.2 Player / Jogador

```cpp
m_iHealth
m_lifeState
m_fFlags
m_iObserverMode
m_hObserverTarget
m_hViewModel
m_vecViewOffset
m_vecVelocity
m_vecBaseVelocity
m_flMaxspeed
m_flFallVelocity
m_nTickBase
m_nNextThinkTick
m_iDefaultFOV
m_hGroundEntity
m_hConstraintEntity
m_flDuckAmount
m_flDuckSpeed
m_bDucked
m_bDucking
m_bInDuckJump
m_iFOV
m_iFOVStart
m_flFOVTime
m_iBonusProgress
m_iBonusChallenge
```

---

## 1.3 CSPlayer específico

```cpp
m_iAccount
m_ArmorValue
m_bHasHelmet
m_bHasDefuser
m_bIsScoped
m_bIsDefusing
m_bIsGrabbingHostage
m_bGunGameImmunity
m_bIsPlayerGhost
m_bHasNightVision
m_bNightVisionOn
m_iShotsFired
m_aimPunchAngle
m_aimPunchAngleVel
m_viewPunchAngle
m_angEyeAngles
m_flFlashDuration
m_flFlashMaxAlpha
m_flLowerBodyYawTarget
m_bSpotted
m_bSpottedByMask
m_bWaitForNoAttack
m_bResumeZoom
m_flVelocityModifier
m_iMoveState
m_flThirdpersonRecoil
m_bStrafing
m_flStamina
m_iDirection
m_iAddonBits
m_iPrimaryAddon
m_iSecondaryAddon
m_iProgressBarDuration
m_flProgressBarStartTime
m_bPlayerDominated
m_bPlayerDominatingMe
```

---

## 1.4 Armas

```cpp
m_hActiveWeapon
m_hMyWeapons
m_hMyWearables
m_iClip1
m_iClip2
m_iPrimaryReserveAmmoCount
m_iSecondaryReserveAmmoCount
m_flNextPrimaryAttack
m_flNextSecondaryAttack
m_flTimeWeaponIdle
m_iState
m_iWeaponID
m_weaponMode
m_fAccuracyPenalty
m_flRecoilIndex
m_zoomLevel
m_bBurstMode
m_flPostponeFireReadyTime
m_bReloadVisuallyComplete
m_flDoneSwitchingSilencer
m_iItemDefinitionIndex
m_iEntityQuality
m_iItemIDHigh
m_iItemIDLow
m_iAccountID
m_OriginalOwnerXuidLow
m_OriginalOwnerXuidHigh
m_nFallbackPaintKit
m_nFallbackSeed
m_flFallbackWear
m_nFallbackStatTrak
m_szCustomName
```

---

## 1.5 Granadas

```cpp
m_bPinPulled
m_fThrowTime
m_flThrowStrength
m_vecThrowVelocity
m_DmgRadius
m_flDamage
m_hThrower
m_nExplodeEffectTickBegin
m_vecExplodeEffectOrigin
m_nSmokeEffectTickBegin
m_bDidSmokeEffect
```

---

## 1.6 C4 / Bomba

```cpp
m_bBombTicking
m_flC4Blow
m_nBombSite
m_bBombDefused
m_hBombDefuser
m_flDefuseCountDown
m_flDefuseLength
m_flTimerLength
m_bBombDropped
m_bBombPlanted
m_bStartedArming
m_fArmedTime
```

---

## 1.7 Ragdoll / Corpo

```cpp
m_ragPos
m_ragAngles
m_hPlayer
m_iDeathPose
m_iDeathFrame
m_flDeathYaw
m_flAbsYaw
m_bClientSideAnimation
m_bClientSideFrameReset
```

---

## 1.8 View Model / Mãos e arma na tela

```cpp
m_nViewModelIndex
m_hWeapon
m_hOwner
m_nSequence
m_flPlaybackRate
m_fCycle
m_nAnimationParity
m_nNewSequenceParity
m_nResetEventsParity
m_nMuzzleFlashParity
```

---

## 1.9 Game Rules / Round

```cpp
m_bFreezePeriod
m_bWarmupPeriod
m_fWarmupPeriodEnd
m_fWarmupPeriodStart
m_bTerroristTimeOutActive
m_bCTTimeOutActive
m_flTerroristTimeOutRemaining
m_flCTTimeOutRemaining
m_nTerroristTimeOuts
m_nCTTimeOuts
m_iRoundTime
m_gamePhase
m_totalRoundsPlayed
m_nOvertimePlaying
m_timeUntilNextPhaseStarts
m_flRestartRoundTime
m_bMapHasBombTarget
m_bMapHasRescueZone
m_bHasMatchStarted
m_bBombDropped
m_bBombPlanted
m_iHostagesRemaining
m_bAnyHostageReached
m_bTCantBuy
m_bCTCantBuy
```

---

# 2. Todas as flags principais de `m_fFlags` / `FL_*`

O campo `m_fFlags` funciona como uma **bitmask**.  
Cada flag representa um bit ligado/desligado para indicar estados da entidade ou jogador.

```cpp
FL_ONGROUND                 = 1 << 0   // 1
FL_DUCKING                  = 1 << 1   // 2
FL_ANIMDUCKING              = 1 << 2   // 4
FL_WATERJUMP                = 1 << 3   // 8
FL_ONTRAIN                  = 1 << 4   // 16
FL_INRAIN                   = 1 << 5   // 32
FL_FROZEN                   = 1 << 6   // 64
FL_ATCONTROLS               = 1 << 7   // 128
FL_CLIENT                   = 1 << 8   // 256
FL_FAKECLIENT               = 1 << 9   // 512
FL_INWATER                  = 1 << 10  // 1024
FL_FLY                      = 1 << 11  // 2048
FL_SWIM                     = 1 << 12  // 4096
FL_CONVEYOR                 = 1 << 13  // 8192
FL_NPC                      = 1 << 14  // 16384
FL_GODMODE                  = 1 << 15  // 32768
FL_NOTARGET                 = 1 << 16  // 65536
FL_AIMTARGET                = 1 << 17  // 131072
FL_PARTIALGROUND            = 1 << 18  // 262144
FL_STATICPROP               = 1 << 19  // 524288
FL_GRAPHED                  = 1 << 20  // 1048576
FL_GRENADE                  = 1 << 21  // 2097152
FL_STEPMOVEMENT             = 1 << 22  // 4194304
FL_DONTTOUCH                = 1 << 23  // 8388608
FL_BASEVELOCITY             = 1 << 24  // 16777216
FL_WORLDBRUSH               = 1 << 25  // 33554432
FL_OBJECT                   = 1 << 26  // 67108864
FL_KILLME                   = 1 << 27  // 134217728
FL_ONFIRE                   = 1 << 28  // 268435456
FL_DISSOLVING               = 1 << 29  // 536870912
FL_TRANSRAGDOLL             = 1 << 30  // 1073741824
FL_UNBLOCKABLE_BY_PLAYER    = 1 << 31  // 2147483648
```

---

# 3. Outras flags famosas além de `m_fFlags`

## 3.1 Input Buttons / Comandos do jogador

Essas flags representam botões ou comandos de entrada.

```cpp
IN_ATTACK
IN_JUMP
IN_DUCK
IN_FORWARD
IN_BACK
IN_USE
IN_CANCEL
IN_LEFT
IN_RIGHT
IN_MOVELEFT
IN_MOVERIGHT
IN_ATTACK2
IN_RUN
IN_RELOAD
IN_ALT1
IN_ALT2
IN_SCORE
IN_SPEED
IN_WALK
IN_ZOOM
IN_WEAPON1
IN_WEAPON2
IN_BULLRUSH
IN_GRENADE1
IN_GRENADE2
IN_ATTACK3
```

---

## 3.2 MoveType

Define o tipo de movimentação da entidade.

```cpp
MOVETYPE_NONE
MOVETYPE_ISOMETRIC
MOVETYPE_WALK
MOVETYPE_STEP
MOVETYPE_FLY
MOVETYPE_FLYGRAVITY
MOVETYPE_VPHYSICS
MOVETYPE_PUSH
MOVETYPE_NOCLIP
MOVETYPE_LADDER
MOVETYPE_OBSERVER
MOVETYPE_CUSTOM
```

---

## 3.3 SolidType

Define o tipo de colisão/sólido da entidade.

```cpp
SOLID_NONE
SOLID_BSP
SOLID_BBOX
SOLID_OBB
SOLID_OBB_YAW
SOLID_CUSTOM
SOLID_VPHYSICS
```

---

## 3.4 Solid Flags / `FSOLID_*`

Flags relacionadas ao comportamento de colisão.

```cpp
FSOLID_CUSTOMRAYTEST
FSOLID_CUSTOMBOXTEST
FSOLID_NOT_SOLID
FSOLID_TRIGGER
FSOLID_NOT_STANDABLE
FSOLID_VOLUME_CONTENTS
FSOLID_FORCE_WORLD_ALIGNED
FSOLID_USE_TRIGGER_BOUNDS
FSOLID_ROOT_PARENT_ALIGNED
```

---

# 4. Termos mais lembrados

As netvars mais conhecidas e frequentemente citadas em análises do CS:GO são:

```cpp
m_flSimulationTime
m_vecOrigin
m_vecVelocity
m_fFlags
m_iHealth
m_iTeamNum
m_angEyeAngles
m_aimPunchAngle
m_hActiveWeapon
m_iShotsFired
m_bIsScoped
m_flFlashDuration
m_nTickBase
m_flLowerBodyYawTarget
```

---

# 5. Fontes úteis para estudo

- Valve Developer Community — Source Engine / datamaps / netprops
- Source SDK 2013 — arquivos públicos da Valve, como `const.h`
- Dumps de netprops/datamaps da build específica do jogo
- Documentação SourceMod para desenvolvimento de plugins legítimos

---

## Nota final

Para obter uma lista literalmente completa, é necessário consultar um **netprop/datamap dump da build exata** do jogo.  
Este arquivo serve como uma referência organizada dos nomes mais comuns e das flags principais.
