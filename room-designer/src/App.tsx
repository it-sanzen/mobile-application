import { useEffect } from 'react';
import { useDesignerStore } from './store/designerStore';
import ShowroomPicker from './components/showroom-picker/ShowroomPicker';
import DesignerLayout from './components/designer/DesignerLayout';
import ShoppingList from './components/shopping-list/ShoppingList';
import LoadingSpinner from './components/shared/LoadingSpinner';

export default function App() {
  const view = useDesignerStore((s) => s.view);
  const isLoading = useDesignerStore((s) => s.isLoading);
  const initialize = useDesignerStore((s) => s.initialize);

  useEffect(() => {
    initialize();
  }, [initialize]);

  if (isLoading && view === 'showroom-picker') {
    return <LoadingSpinner />;
  }

  switch (view) {
    case 'designer':
      return <DesignerLayout />;
    case 'shopping-list':
      return <ShoppingList />;
    default:
      return <ShowroomPicker />;
  }
}
