import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { PrimaryButton, StepHeader } from './Shared';
import { CheckCircle2, ShoppingCart } from 'lucide-react';
const finalOrder = [
{
  id: 1,
  name: 'Pan Bimbo Grande',
  qty: 4,
  price: 180
},
{
  id: 2,
  name: 'Roles Canela',
  qty: 2,
  price: 120
},
{
  id: 3,
  name: 'Donas Bimbo',
  qty: 3,
  price: 150
},
{
  id: 4,
  name: 'Gansito',
  qty: 2,
  price: 200
}];

export const ConfirmScreen = ({ onNext }: {onNext: () => void;}) => {
  const [vendorApproved, setVendorApproved] = useState(false);
  const [storeApproved, setStoreApproved] = useState(false);
  const total = finalOrder.reduce((acc, item) => acc + item.price, 0);
  const totalItems = finalOrder.reduce((acc, item) => acc + item.qty, 0);
  const canConfirm = vendorApproved && storeApproved;
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
        step={5}
        title="Confirmación"
        subtitle="Revisión final del pedido" />
      

      <div className="flex-1 overflow-y-auto p-6 pb-32">
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden mb-6">
          <div className="bg-gray-50 p-4 border-b border-gray-100 flex justify-between items-center">
            <span className="font-bold text-gray-800 flex items-center gap-2">
              <ShoppingCart size={18} className="text-bimbo-navy" />
              Resumen
            </span>
            <span className="text-sm text-gray-500">{totalItems} cajas</span>
          </div>

          <div className="p-4 space-y-3">
            {finalOrder.map((item) =>
            <div
              key={item.id}
              className="flex justify-between items-center text-sm">
              
                <div className="flex gap-2">
                  <span className="font-bold text-gray-700 w-4">
                    {item.qty}
                  </span>
                  <span className="text-gray-600">{item.name}</span>
                </div>
                <span className="font-medium text-gray-800">${item.price}</span>
              </div>
            )}

            <div className="border-t border-dashed border-gray-200 pt-3 mt-3 flex justify-between items-center">
              <span className="font-bold text-gray-800">Total a pagar</span>
              <span className="font-bold text-xl text-bimbo-navy">
                ${total}
              </span>
            </div>
          </div>
        </div>

        <h3 className="font-bold text-gray-800 mb-4 text-center">
          Aprobación requerida
        </h3>

        <div className="grid grid-cols-2 gap-4">
          {/* Vendor Side */}
          <motion.button
            whileTap={{
              scale: 0.95
            }}
            onClick={() => setVendorApproved(!vendorApproved)}
            className={`p-4 rounded-2xl border-2 flex flex-col items-center justify-center gap-3 transition-colors ${vendorApproved ? 'bg-green-50 border-green-500 text-green-700' : 'bg-white border-gray-200 text-gray-500'}`}>
            
            <div
              className={`w-12 h-12 rounded-full flex items-center justify-center ${vendorApproved ? 'bg-green-500 text-white' : 'bg-gray-100 text-gray-400'}`}>
              
              {vendorApproved ?
              <CheckCircle2 size={24} /> :

              <span className="font-bold text-xl">C</span>
              }
            </div>
            <span className="font-bold text-sm">Vendedor</span>
          </motion.button>

          {/* Store Side */}
          <motion.button
            whileTap={{
              scale: 0.95
            }}
            onClick={() => setStoreApproved(!storeApproved)}
            className={`p-4 rounded-2xl border-2 flex flex-col items-center justify-center gap-3 transition-colors ${storeApproved ? 'bg-green-50 border-green-500 text-green-700' : 'bg-white border-gray-200 text-gray-500'}`}>
            
            <div
              className={`w-12 h-12 rounded-full flex items-center justify-center ${storeApproved ? 'bg-green-500 text-white' : 'bg-gray-100 text-gray-400'}`}>
              
              {storeApproved ?
              <CheckCircle2 size={24} /> :

              <span className="font-bold text-xl">L</span>
              }
            </div>
            <span className="font-bold text-sm">Doña Lupita</span>
          </motion.button>
        </div>
      </div>

      <div className="absolute bottom-0 inset-x-0 p-6 bg-white border-t border-gray-100 shadow-[0_-10px_20px_rgba(0,0,0,0.05)]">
        <PrimaryButton
          onClick={onNext}
          disabled={!canConfirm}
          variant={canConfirm ? 'success' : 'primary'}>
          
          {canConfirm ? 'Confirmar Pedido' : 'Faltan firmas'}
        </PrimaryButton>
      </div>
    </motion.div>);

};