import { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import api from '../api';
import { Clock, LogOut, Trash2, CheckCircle2 } from 'lucide-react';

export default function TimelineManager() {
    const [properties, setProperties] = useState([]);
    const [selectedPropertyId, setSelectedPropertyId] = useState('');
    const [milestones, setMilestones] = useState([]);

    const [formData, setFormData] = useState({
        phase: 'Structure',
        title: '',
        description: '',
        status: 'PENDING',
        estimatedDate: '',
        orderIndex: 0
    });

    const [status, setStatus] = useState({ type: '', message: '' });
    const [isLoading, setIsLoading] = useState(false);
    const navigate = useNavigate();
    const user = JSON.parse(localStorage.getItem('admin_user') || '{}');

    // Fetch all properties on mount
    useEffect(() => {
        const fetchProperties = async () => {
            try {
                const res = await api.get('/properties/all');
                setProperties(res.data);
                if (res.data.length > 0) {
                    setSelectedPropertyId(res.data[0].id);
                }
            } catch (error) {
                console.error('Failed to fetch properties:', error);
            }
        };
        fetchProperties();
    }, []);

    // Fetch milestones whenever the selected property changes
    useEffect(() => {
        const fetchMilestones = async () => {
            if (!selectedPropertyId) return;
            try {
                const res = await api.get(`/timeline/${selectedPropertyId}`);
                setMilestones(res.data);
            } catch (error) {
                console.error('Failed to fetch milestones:', error);
            }
        };
        fetchMilestones();
    }, [selectedPropertyId]);

    const handleLogout = () => {
        localStorage.removeItem('admin_token');
        localStorage.removeItem('admin_user');
        navigate('/login');
    };

    const handlePropertyChange = (e) => {
        setSelectedPropertyId(e.target.value);
        setMilestones([]); // clear out old
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (!selectedPropertyId) return;

        setIsLoading(true);
        setStatus({ type: '', message: '' });

        try {
            // Need to pass numbers as integers
            const payload = {
                ...formData,
                orderIndex: parseInt(formData.orderIndex, 10),
                completedDate: formData.status === 'COMPLETED' ? new Date().toISOString() : null
            };

            await api.post(`/timeline/${selectedPropertyId}`, payload);
            setStatus({ type: 'success', message: 'Timeline Milestone added successfully!' });

            // Reset form
            setFormData({ phase: 'Structure', title: '', description: '', status: 'PENDING', estimatedDate: '', orderIndex: milestones.length + 1 });

            // Refetch milestones
            const res = await api.get(`/timeline/${selectedPropertyId}`);
            setMilestones(res.data);

        } catch (err) {
            setStatus({ type: 'error', message: err.response?.data?.message || 'Failed to add milestone' });
        } finally {
            setIsLoading(false);
        }
    };

    const handleStatusUpdate = async (milestoneId, newStatus) => {
        try {
            const payload = {
                status: newStatus,
                completedDate: newStatus === 'COMPLETED' ? new Date().toISOString() : null
            };
            await api.patch(`/timeline/milestone/${milestoneId}`, payload);

            // Refetch
            const res = await api.get(`/timeline/${selectedPropertyId}`);
            setMilestones(res.data);
        } catch (error) {
            alert('Failed to update status');
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm('Are you sure you want to delete this construction milestone?')) return;
        try {
            await api.delete(`/timeline/milestone/${id}`);
            const res = await api.get(`/timeline/${selectedPropertyId}`);
            setMilestones(res.data);
        } catch (error) {
            alert('Failed to delete milestone');
        }
    };

    return (
        <div className="min-h-screen bg-gray-50 flex flex-col">
            <nav className="bg-white border-b border-gray-200">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="flex justify-between h-16">
                        <div className="flex items-center space-x-8">
                            <div className="flex items-center">
                                <span className="text-xl font-bold text-gray-900">Admin Portal</span>
                            </div>
                            <div className="hidden sm:flex sm:space-x-4">
                                <Link to="/dashboard" className="text-gray-500 hover:text-gray-700 px-3 py-2 text-sm font-medium">Users</Link>
                                <Link to="/documents" className="text-gray-500 hover:text-gray-700 px-3 py-2 text-sm font-medium">Documents</Link>
                                <Link to="/company-news" className="text-gray-500 hover:text-gray-700 px-3 py-2 text-sm font-medium">Company News</Link>
                                <Link to="/unit-updates" className="text-gray-500 hover:text-gray-700 px-3 py-2 text-sm font-medium">Unit Updates</Link>
                                <Link to="/timeline" className="text-blue-600 border-b-2 border-blue-600 px-3 py-2 text-sm font-medium">Timelines</Link>
                                <Link to="/properties" className="text-gray-500 hover:text-gray-700 px-3 py-2 text-sm font-medium">Properties</Link>
                            </div>
                        </div>
                        <div className="flex items-center space-x-4">
                            <span className="text-sm text-gray-600">Welcome, {user.name}</span>
                            <button onClick={handleLogout} className="flex items-center text-sm font-medium text-gray-500 hover:text-gray-900">
                                <LogOut className="w-4 h-4 mr-1" /> Logout
                            </button>
                        </div>
                    </div>
                </div>
            </nav>

            <main className="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-10">
                <div className="mb-8">
                    <h2 className="text-2xl font-bold text-gray-900">Property Timeline Manager</h2>
                    <p className="mt-1 text-sm text-gray-600">Select a property from the database and inject construction milestones.</p>

                    <div className="mt-4">
                        <label className="block text-sm font-medium text-gray-700 mb-2">Select Target Property</label>
                        <select
                            value={selectedPropertyId}
                            onChange={handlePropertyChange}
                            className="block w-full max-w-lg border border-gray-300 rounded-md py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-lg"
                        >
                            <option value="" disabled>Loading properties...</option>
                            {properties.map(p => (
                                <option key={p.id} value={p.id}>{p.name} ({p.location})</option>
                            ))}
                        </select>
                    </div>
                </div>

                {selectedPropertyId && (
                    <div className="md:grid md:grid-cols-3 md:gap-8">
                        <div className="md:col-span-1">
                            {status.message && (
                                <div className={`mb-4 p-4 rounded-md flex ${status.type === 'success' ? 'bg-green-50' : 'bg-red-50'}`}>
                                    {status.type === 'success' && <CheckCircle2 className="h-5 w-5 text-green-400 mr-2" />}
                                    <span className={`text-sm font-medium ${status.type === 'success' ? 'text-green-800' : 'text-red-800'}`}>
                                        {status.message}
                                    </span>
                                </div>
                            )}

                            <form onSubmit={handleSubmit} className="space-y-4 bg-white p-6 shadow sm:rounded-md">
                                <h3 className="text-lg font-medium leading-6 text-gray-900 border-b pb-2">Add New Milestone</h3>

                                <div>
                                    <label className="block text-sm font-medium text-gray-700">Construction Phase</label>
                                    <input type="text" placeholder="e.g. MEP, Foundations, Finishing" required value={formData.phase} onChange={(e) => setFormData({ ...formData, phase: e.target.value })} className="mt-1 block w-full border border-gray-300 rounded-md py-2 px-3 sm:text-sm" />
                                </div>

                                <div>
                                    <label className="block text-sm font-medium text-gray-700">Milestone Title</label>
                                    <input type="text" placeholder="e.g. Concrete Pouring" required value={formData.title} onChange={(e) => setFormData({ ...formData, title: e.target.value })} className="mt-1 block w-full border border-gray-300 rounded-md py-2 px-3 sm:text-sm" />
                                </div>

                                <div>
                                    <label className="block text-sm font-medium text-gray-700">Description</label>
                                    <textarea rows={2} required value={formData.description} onChange={(e) => setFormData({ ...formData, description: e.target.value })} className="mt-1 block w-full border border-gray-300 rounded-md py-2 px-3 sm:text-sm" />
                                </div>

                                <div className="grid grid-cols-2 gap-4">
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700">Status</label>
                                        <select value={formData.status} onChange={(e) => setFormData({ ...formData, status: e.target.value })} className="mt-1 block w-full border border-gray-300 rounded-md py-2 px-3 sm:text-sm">
                                            <option value="PENDING">Pending</option>
                                            <option value="IN_PROGRESS">In Progress</option>
                                            <option value="COMPLETED">Completed</option>
                                            <option value="DELAYED">Delayed</option>
                                        </select>
                                    </div>
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700">Order (Graph Position)</label>
                                        <input type="number" required value={formData.orderIndex} onChange={(e) => setFormData({ ...formData, orderIndex: e.target.value })} className="mt-1 block w-full border border-gray-300 rounded-md py-2 px-3 sm:text-sm" />
                                    </div>
                                </div>

                                <div>
                                    <label className="block text-sm font-medium text-gray-700">Estimated Date String</label>
                                    <input type="text" placeholder="e.g. Q3 2026 or Aug 15th" value={formData.estimatedDate} onChange={(e) => setFormData({ ...formData, estimatedDate: e.target.value })} className="mt-1 block w-full border border-gray-300 rounded-md py-2 px-3 sm:text-sm" />
                                </div>

                                <button type="submit" disabled={isLoading} className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50">
                                    {isLoading ? 'Injecting...' : 'Inject Milestone'}
                                </button>
                            </form>
                        </div>

                        <div className="md:col-span-2 mt-8 md:mt-0">
                            <div className="bg-white shadow overflow-hidden sm:rounded-md p-4">
                                <h3 className="text-lg font-medium leading-6 text-gray-900 mb-4 px-2">Current Milestones ({milestones.length})</h3>
                                <ul className="divide-y divide-gray-200">
                                    {milestones.length === 0 ? (
                                        <li className="px-6 py-12 text-center text-gray-500">No milestones yet for this property.</li>
                                    ) : (
                                        milestones.map((m) => (
                                            <li key={m.id} className="px-4 py-4 sm:px-6 flex flex-col sm:flex-row sm:justify-between sm:items-center hover:bg-gray-50 border border-gray-100 rounded-lg mb-2">
                                                <div className="flex items-start">
                                                    <div className="flex-shrink-0 mt-1">
                                                        <Clock className="h-6 w-6 text-gray-400" />
                                                    </div>
                                                    <div className="ml-4">
                                                        <div className="text-sm font-bold text-gray-900">{m.orderIndex}. {m.phase}: {m.title}</div>
                                                        <div className="text-sm text-gray-500 mt-1">{m.description}</div>
                                                        <div className="text-xs text-gray-400 mt-2 font-mono">ID: {m.id} • Est: {m.estimatedDate || 'N/A'}</div>
                                                    </div>
                                                </div>
                                                <div className="mt-4 sm:mt-0 flex items-center space-x-3">
                                                    <select
                                                        value={m.status}
                                                        onChange={(e) => handleStatusUpdate(m.id, e.target.value)}
                                                        className={`text-xs font-bold py-1 px-2 rounded-full border-0 shadow-sm
                                                            ${m.status === 'COMPLETED' ? 'bg-green-100 text-green-800' :
                                                                m.status === 'IN_PROGRESS' ? 'bg-yellow-100 text-yellow-800' :
                                                                    m.status === 'DELAYED' ? 'bg-red-100 text-red-800' : 'bg-gray-100 text-gray-800'}`}
                                                    >
                                                        <option value="PENDING">PENDING</option>
                                                        <option value="IN_PROGRESS">IN PROGRESS</option>
                                                        <option value="COMPLETED">COMPLETED</option>
                                                        <option value="DELAYED">DELAYED</option>
                                                    </select>

                                                    <button onClick={() => handleDelete(m.id)} className="text-red-600 hover:text-red-900 p-2 border rounded-md hover:bg-red-50">
                                                        <Trash2 className="h-4 w-4" />
                                                    </button>
                                                </div>
                                            </li>
                                        ))
                                    )}
                                </ul>
                            </div>
                        </div>
                    </div>
                )}
            </main>
        </div>
    );
}
