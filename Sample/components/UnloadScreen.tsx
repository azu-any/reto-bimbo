import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { PrimaryButton, StepHeader, OsitoFAB } from './Shared';
import { CheckCircle2, ChevronRight, Package } from 'lucide-react';
const mockProducts = [
{
  id: 1,
  name: 'Pan Bimbo Grande',
  qty: 3,
  checked: false
},
{
  id: 2,
  name: 'Donas Bimbo',
  qty: 2,
  checked: false
},
{
  id: 3,
  name: 'Mantecadas',
  qty: 2,
  checked: false
},
{
  id: 4,
  name: 'Tortillinas Tía Rosa',
  qty: 1,
  checked: false
}];

export const UnloadScreen = ({ onNext }: {onNext: () => void;}) => {
  const [products, setProducts] = useState(mockProducts);
  const toggleProduct = (id: number) => {
    setProducts(
      products.map((p) =>
      p.id === id ?
      {
        ...p,
        checked: !p.checked
      } :
      p
      )
    );
  };
  const checkedCount = products.filter((p) => p.checked).length;
  const totalCount = products.length;
  const isAllChecked = checkedCount === totalCount;
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
        step={1}
        title="Bajar del camión"
        subtitle="Pedido de la semana pasada" />
      

      <div className="flex-1 overflow-y-auto p-6 pb-24">
        <div className="flex justify-between items-center mb-6">
          <span className="text-sm font-medium text-gray-500">Progreso</span>
          <span className="text-sm font-bold text-bimbo-navy">
            {checkedCount}/{totalCount} cajas
          </span>
        </div>

        <div className="w-full bg-gray-200 rounded-full h-2 mb-8">
          <motion.div
            className="bg-bimbo-navy h-2 rounded-full"
            initial={{
              width: 0
            }}
            animate={{
              width: `${checkedCount / totalCount * 100}%`
            }} />
          
        </div>

        <div className="space-y-3">
          {products.map((product, index) =>
          <motion.div
            key={product.id}
            initial={{
              opacity: 0,
              y: 20
            }}
            animate={{
              opacity: 1,
              y: 0
            }}
            transition={{
              delay: index * 0.1
            }}
            onClick={() => toggleProduct(product.id)}
            className={`p-4 rounded-2xl border-2 transition-all cursor-pointer flex items-center gap-4 ${product.checked ? 'bg-green-50 border-green-200' : 'bg-white border-transparent shadow-sm'}`}>
            
              <div
              className={`w-12 h-12 rounded-xl flex items-center justify-center ${product.checked ? 'bg-green-100 text-green-600' : 'bg-bimbo-cream text-bimbo-navy'}`}>
              
                <Package size={24} />
              </div>

              <div className="flex-1">
                <h3
                className={`font-semibold ${product.checked ? 'text-gray-500 line-through' : 'text-gray-800'}`}>
                
                  {product.name}
                </h3>
                <p className="text-sm text-gray-500">{product.qty} cajas</p>
              </div>

              <div
              className={`w-6 h-6 rounded-full border-2 flex items-center justify-center ${product.checked ? 'bg-green-500 border-green-500' : 'border-gray-300'}`}>
              
                {product.checked &&
              <CheckCircle2 size={16} className="text-white" />
              }
              </div>
            </motion.div>
          )}
        </div>
      </div>

      <div className="absolute bottom-0 inset-x-0 p-6 bg-gradient-to-t from-gray-50 via-gray-50 to-transparent">
        <PrimaryButton
          onClick={onNext}
          disabled={!isAllChecked}
          variant={isAllChecked ? 'success' : 'primary'}>
          
          {isAllChecked ?
          'Listo, todo bajado' :
          'Selecciona todo para continuar'}
          <ChevronRight size={20} />
        </PrimaryButton>
      </div>

      <OsitoFAB tip="Asegúrate de llevar el diablito, ¡son varias cajas hoy!" />
    </motion.div>);

};