import React, { useState } from 'react';
import { AnimatePresence } from 'framer-motion';
import { PhoneFrame } from './components/Shared';
import { SplashScreen } from './components/SplashScreen';
import { MapScreen } from './components/MapScreen';
import { ArrivalScreen } from './components/ArrivalScreen';
import { UnloadScreen } from './components/UnloadScreen';
import { ExpiringScreen } from './components/ExpiringScreen';
import { RestockScreen } from './components/RestockScreen';
import { AIRecommendScreen } from './components/AIRecommendScreen';
import { ConfirmScreen } from './components/ConfirmScreen';
import { NotesScreen } from './components/NotesScreen';
import { SuccessScreen } from './components/SuccessScreen';
export function App() {
  const [step, setStep] = useState(0);
  const nextStep = () => {
    if (step < 9) {
      setStep(step + 1);
    } else {
      setStep(1); // Loop back to map
    }
  };
  return (
    <PhoneFrame>
      <AnimatePresence mode="wait">
        {step === 0 && <SplashScreen key="splash" onNext={nextStep} />}
        {step === 1 && <MapScreen key="map" onNext={nextStep} />}
        {step === 2 && <ArrivalScreen key="arrival" onNext={nextStep} />}
        {step === 3 && <UnloadScreen key="unload" onNext={nextStep} />}
        {step === 4 && <ExpiringScreen key="expiring" onNext={nextStep} />}
        {step === 5 && <RestockScreen key="restock" onNext={nextStep} />}
        {step === 6 && <AIRecommendScreen key="ai" onNext={nextStep} />}
        {step === 7 && <ConfirmScreen key="confirm" onNext={nextStep} />}
        {step === 8 && <NotesScreen key="notes" onNext={nextStep} />}
        {step === 9 && <SuccessScreen key="success" onNext={nextStep} />}
      </AnimatePresence>
    </PhoneFrame>);

}