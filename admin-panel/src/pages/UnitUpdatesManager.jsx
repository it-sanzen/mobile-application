import { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import api from '../api';
import { Hammer, LogOut, Trash2, CheckCircle2 } from 'lucide-react';

export default function UnitUpdatesManager() {
    const [users, setUsers] = useState([]);
    const [selectedUserId, setSelectedUserId] = useState('');
    const [updates, setUpdates] = useState([]);

    const [formData, setFormData] = useState({
        updateType: 'CONSTRUCTION',
        title: '',
        description: '',
        time: '',
        isPublished: true
    });

    const [status, setStatus] = useState({ type: '', message: '' });
    const [isLoading, setIsLoading] = useState(false);
    const navigate = useNavigate();
    const adminUser = JSON.parse(localStorage.getItem('admin_user') || '{}');

    useEffect(() => {
        const fetchUsers = async () => {
            try {
                const res = await api.get('/admin/users');
                setUsers(res.data);
                if (res.data.length > 0) {
                    setSelectedUserId(res.data[0].id);
                }
            } catch (error) {
                console.error('Failed to fetch users:', error);
            }
        };
        fetchUsers();
    }, []);

    // Not fetching the specific updates yet because we don't have an admin route to fetch by user.
    // To simplify, we will just allow creating them.

    const handleLogout = () => {
        localStorage.removeItem('admin_token');
        localStorage.removeItem('admin_user');
        navigate('/login');
    };

    const handleUserChange = (e) => {
        setSelectedUserId(e.target.value);
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (!selectedUserId) return;

        setIsLoading(true);
        setStatus({ type: '', message: '' });

        try {
            const payload = {
                ...formData,
                userId: selectedUserId
            };

            await api.post(`/unit-updates`, payload);
            setStatus({ type: 'success', message: 'Targeted Unit Update deployed successfully! The user will be notified.' });

            // Reset form
            setFormData({ updateType: 'CONSTRUCTION', title: '', description: '', time: '', isPublished: true });

        } catch (err) {
            setStatus({ type: 'error', message: err.response?.data?.message || 'Failed to dispatch update' });
        } finally {
            setIsLoading(false);
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
                                <Link to="/unit-updates" className="text-blue-600 border-b-2 border-blue-600 px-3 py-2 text-sm font-medium">Unit Updates</Link>
                                <Link to="/timeline" className="text-gray-500 hover:text-gray-700 px-3 py-2 text-sm font-medium">Timelines</Link>
                                <Link to="/properties" className="text-gray-500 hover:text-gray-700 px-3 py-2 text-sm font-medium">Properties</Link>
                            </div>
                        </div>
                        <div className="flex items-center space-x-4">
                            <span className="text-sm text-gray-600">Welcome, {adminUser.name}</span>
                            <button onClick={handleLogout} className="flex items-center text-sm font-medium text-gray-500 hover:text-gray-900">
                                <LogOut className="w-4 h-4 mr-1" /> Logout
                            </button>
                        </div>
                    </div>
                </div>
            </nav>

            <main className="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-10">
                <div className="mb-8">
                    <h2 className="text-2xl font-bold text-gray-900">Deploy Targeted Unit Update</h2>
                    <p className="mt-1 text-sm text-gray-600">Provide personal construction statuses or notices to an individual user's app.</p>
                </div>

                <div className="max-w-3xl">
                    {status.message && (
                        <div className={`mb-6 p-4 rounded-md flex ${status.type === 'success' ? 'bg-green-50' : 'bg-red-50'}`}>
                            {status.type === 'success' && <CheckCircle2 className="h-5 w-5 text-green-400 mr-2" />}
                            <span className={`text-sm font-medium ${status.type === 'success' ? 'text-green-800' : 'text-red-800'}`}>
                                {status.message}
                            </span>
                        </div>
                    )}

                    <form onSubmit={handleSubmit} className="space-y-6 bg-white p-8 shadow sm:rounded-lg">

                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-2">Select Target User</label>
                            <select
                                value={selectedUserId}
                                onChange={handleUserChange}
                                required
                                className="block w-full border border-gray-300 rounded-md py-3 px-4 focus:ring-blue-500 focus:border-blue-500 sm:text-lg bg-gray-50"
                            >
                                <option value="" disabled>Loading users...</option>
                                {users.map(u => (
                                    <option key={u.id} value={u.id}>{u.name} ({u.email})</option>
                                ))}
                            </select>
                        </div>

                        <div className="grid grid-cols-2 gap-6 pt-4 border-t">
                            <div className="col-span-2">
                                <label className="block text-sm font-medium text-gray-700">Update Title</label>
                                <input type="text" placeholder="e.g. Electrical Wiring Completed" required value={formData.title} onChange={(e) => setFormData({ ...formData, title: e.target.value })} className="mt-1 block w-full border border-gray-300 rounded-md py-2 px-3 sm:text-sm" />
                            </div>

                            <div className="col-span-1">
                                <label className="block text-sm font-medium text-gray-700">Category Tag</label>
                                <select value={formData.updateType} onChange={(e) => setFormData({ ...formData, updateType: e.target.value })} className="mt-1 block w-full border border-gray-300 rounded-md py-2 px-3 sm:text-sm">
                                    <option value="GENERAL">General</option>
                                    <option value="CONSTRUCTION">Construction</option>
                                    <option value="PLUMBING">Plumbing</option>
                                    <option value="ELECTRICAL">Electrical</option>
                                    <option value="INSPECTION">Inspection</option>
                                    <option value="MILESTONE">Milestone</option>
                                </select>
                            </div>

                            <div className="col-span-1">
                                <label className="block text-sm font-medium text-gray-700">Time Label</label>
                                <input type="text" placeholder="e.g. 2 hours ago or Today" required value={formData.time} onChange={(e) => setFormData({ ...formData, time: e.target.value })} className="mt-1 block w-full border border-gray-300 rounded-md py-2 px-3 sm:text-sm" />
                            </div>

                            <div className="col-span-2">
                                <label className="block text-sm font-medium text-gray-700">Message Content</label>
                                <textarea rows={4} required value={formData.description} onChange={(e) => setFormData({ ...formData, description: e.target.value })} className="mt-1 block w-full border border-gray-300 rounded-md py-2 px-3 sm:text-sm" />
                            </div>
                        </div>

                        <div className="pt-2">
                            <button type="submit" disabled={isLoading} className="w-full flex justify-center py-3 px-4 border border-transparent rounded-md shadow-sm text-lg font-bold text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50">
                                {isLoading ? 'Dispatching...' : 'Dispatch Update to App'}
                            </button>
                        </div>
                    </form>
                </div>
            </main>
        </div>
    );
}
