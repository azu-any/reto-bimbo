import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { PrimaryButton, StepHeader, OsitoFAB } from './Shared';
import { ChevronRight, Mic } from 'lucide-react';
const quickChips = [
'Cambió de dueño',
'Renovó refri',
'Pidió promoción',
'Competencia nueva',
'Cerrado temprano'];

export const NotesScreen = ({ onNext }: {onNext: () => void;}) => {
  const [note, setNote] = useState('');
  const [isRecording, setIsRecording] = useState(false);
  const addChip = (chip: string) => {
    setNote((prev) => prev ? `${prev}, ${chip}` : chip);
  };
  return (
    <motion.div
      initial={{
        opacity: 0,
        x: 50
      }}
      animate={{
        opacity: 1,
        x: 0
      }}
      exit={{
        opacity: 0,
        x: -50
      }}
      className="absolute inset-0 bg-gray-50 flex flex-col">
      
      <StepHeader
        step={6}
        title="Notas del día"
        subtitle="Ayuda a mejorar la ruta" />
      

      <div className="flex-1 overflow-y-auto p-6 pb-24">
        <div className="bg-white rounded-2xl p-4 shadow-sm border border-gray-100 mb-6">
          <textarea
            value={note}
            onChange={(e) => setNote(e.target.value)}
            placeholder="Escribe observaciones, incidencias o cambios en la tienda..."
            className="w-full h-32 resize-none outline-none text-gray-700 placeholder-gray-400" />
          

          <div className="flex justify-between items-center border-t border-gray-100 pt-3 mt-2">
            <span className="text-xs text-gray-400">
              {note.length} caracteres
            </span>
            <button
              onClick={() => setIsRecording(!isRecording)}
              className={`w-10 h-10 rounded-full flex items-center justify-center transition-colors ${isRecording ? 'bg-red-100 text-red-500 animate-pulse' : 'bg-gray-100 text-gray-500 hover:bg-gray-200'}`}>
              
              <Mic size={20} />
            </button>
          </div>
        </div>

        <h3 className="text-sm font-bold text-gray-800 mb-3">
          Etiquetas rápidas
        </h3>
        <div className="flex flex-wrap gap-2">
          {quickChips.map((chip) =>
          <button
            key={chip}
            onClick={() => addChip(chip)}
            className="px-4 py-2 bg-white border border-gray-200 rounded-full text-sm text-gray-600 hover:border-bimbo-navy hover:text-bimbo-navy transition-colors">
            
              {chip}
            </button>
          )}
        </div>
      </div>

      <div className="absolute bottom-0 inset-x-0 p-6 bg-gradient-to-t from-gray-50 via-gray-50 to-transparent">
        <PrimaryButton onClick={onNext}>
          Guardar y finalizar <ChevronRight size={20} />
        </PrimaryButton>
      </div>

      <OsitoFAB tip="¡Anotado! Aprenderé de esto para darte mejores recomendaciones la próxima semana." />
    </motion.div>);

};