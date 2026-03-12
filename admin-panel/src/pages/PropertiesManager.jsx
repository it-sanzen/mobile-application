import { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import api from '../api';
import { Building, LogOut, Plus, Edit2, Trash2, CheckCircle2 } from 'lucide-react';

export default function PropertiesManager() {
    const [properties, setProperties] = useState([]);
    const [isEditing, setIsEditing] = useState(false);
    const [currentId, setCurrentId] = useState(null);
    const [formData, setFormData] = useState({
        name: '',
        location: '',
        propertyType: 'VILLA',
        bedrooms: 0,
        area: 0,
        status: 'UNDER_CONSTRUCTION',
        completionPercentage: 0,
        imageUrl: '',
        unitCode: '',
        currentPhase: '',
        estimatedCompletion: ''
    });
    const [status, setStatus] = useState({ type: '', message: '' });
    const [isLoading, setIsLoading] = useState(false);
    const navigate = useNavigate();
    const user = JSON.parse(localStorage.getItem('admin_user') || '{}');

    const fetchProperties = async () => {
        try {
            const res = await api.get('/properties/all');
            setProperties(res.data);
        } catch (err) {
            console.error('Failed to fetch properties', err);
        }
    };

    useEffect(() => {
        fetchProperties();
    }, []);

    const handleLogout = () => {
        localStorage.removeItem('admin_token');
        localStorage.removeItem('admin_user');
        navigate('/login');
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setIsLoading(true);
        setStatus({ type: '', message: '' });

        const payload = {
            ...formData,
            bedrooms: Number(formData.bedrooms),
            area: Number(formData.area),
            completionPercentage: Number(formData.completionPercentage)
        };

        if (!payload.imageUrl) delete payload.imageUrl;
        if (!payload.currentPhase) delete payload.currentPhase;
        if (!payload.estimatedCompletion) delete payload.estimatedCompletion;

        try {
            if (isEditing) {
                await api.put(`/properties/${currentId}`, payload);
                setStatus({ type: 'success', message: 'Property updated successfully!' });
            } else {
                await api.post('/properties', payload);
                setStatus({ type: 'success', message: 'Property created successfully!' });
            }
            fetchProperties();
            resetForm();
        } catch (err) {
            setStatus({
                type: 'error',
                message: err.response?.data?.message || 'Failed to save property'
            });
        } finally {
            setIsLoading(false);
        }
    };

    const handleEdit = (property) => {
        setIsEditing(true);
        setCurrentId(property.id);
        setFormData({
            name: property.name,
            location: property.location,
            propertyType: property.propertyType,
            bedrooms: property.bedrooms,
            area: property.area,
            status: property.status,
            completionPercentage: property.completionPercentage,
            imageUrl: property.imageUrl || '',
            unitCode: property.unitCode || '',
            currentPhase: property.currentPhase || '',
            estimatedCompletion: property.estimatedCompletion || ''
        });
        window.scrollTo({ top: 0, behavior: 'smooth' });
    };

    const handleDelete = async (id) => {
        if (!window.confirm('Are you sure you want to delete this property?')) return;
        try {
            await api.delete(`/properties/${id}`);
            fetchProperties();
        } catch (err) {
            console.error('Failed to delete', err);
        }
    };

    const resetForm = () => {
        setIsEditing(false);
        setCurrentId(null);
        setFormData({
            name: '',
            location: '',
            propertyType: 'VILLA',
            bedrooms: 0,
            area: 0,
            status: 'UNDER_CONSTRUCTION',
            completionPercentage: 0,
            imageUrl: '',
            unitCode: '',
            currentPhase: '',
            estimatedCompletion: ''
        });
    };

    return (
        <div className="min-h-screen bg-gray-50 flex flex-col">
            <nav className="bg-white border-b border-gray-200">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="flex justify-between h-16">
                        <div className="flex items-center space-x-8">
                            <div className="flex items-center">
                                <Building className="w-8 h-8 text-blue-600 mr-3" />
                                <span className="text-xl font-bold text-gray-900">Admin Portal</span>
                            </div>
                            <div className="hidden sm:flex sm:space-x-4">
                                <Link to="/dashboard" className="text-gray-500 hover:text-gray-700 px-3 py-2 text-sm font-medium">Users</Link>
                                <Link to="/documents" className="text-gray-500 hover:text-gray-700 px-3 py-2 text-sm font-medium">Documents</Link>
                                <Link to="/company-news" className="text-gray-500 hover:text-gray-700 px-3 py-2 text-sm font-medium">Company News</Link>
                                <Link to="/unit-updates" className="text-gray-500 hover:text-gray-700 px-3 py-2 text-sm font-medium">Unit Updates</Link>
                                <Link to="/timeline" className="text-gray-500 hover:text-gray-700 px-3 py-2 text-sm font-medium">Timelines</Link>
                                <Link to="/properties" className="text-blue-600 border-b-2 border-blue-600 px-3 py-2 text-sm font-medium">Properties</Link>
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

            <main className="flex-1 max-w-7xl w-full mx-auto px-4 py-8">
                {/* Form Section */}
                <div className="bg-white rounded-lg shadow-sm border border-gray-200 mb-8 overflow-hidden">
                    <div className="px-6 py-4 border-b border-gray-200 bg-gray-50 flex justify-between items-center">
                        <h2 className="text-lg font-medium text-gray-900">
                            {isEditing ? 'Edit Property' : 'Add New Property'}
                        </h2>
                        {isEditing && (
                            <button onClick={resetForm} className="text-sm text-blue-600 hover:text-blue-800">
                                Cancel Edit
                            </button>
                        )}
                    </div>

                    <div className="p-6">
                        {status.message && (
                            <div className={`mb-4 p-4 rounded-md flex ${status.type === 'success' ? 'bg-green-50' : 'bg-red-50'}`}>
                                {status.type === 'success' && <CheckCircle2 className="h-5 w-5 text-green-400 mr-2" />}
                                <span className={`text-sm font-medium ${status.type === 'success' ? 'text-green-800' : 'text-red-800'}`}>
                                    {status.message}
                                </span>
                            </div>
                        )}

                        <form onSubmit={handleSubmit} className="space-y-4">
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-gray-700">Property Name</label>
                                    <input type="text" required value={formData.name} onChange={e => setFormData({ ...formData, name: e.target.value })} className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3" />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700">Location</label>
                                    <input type="text" required value={formData.location} onChange={e => setFormData({ ...formData, location: e.target.value })} className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3" />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700">Unit Code</label>
                                    <input type="text" required value={formData.unitCode} onChange={e => setFormData({ ...formData, unitCode: e.target.value })} className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3" />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700">Property Type</label>
                                    <select value={formData.propertyType} onChange={e => setFormData({ ...formData, propertyType: e.target.value })} className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3">
                                        <option value="VILLA">Villa</option>
                                        <option value="APARTMENT">Apartment</option>
                                        <option value="TOWNHOUSE">Townhouse</option>
                                        <option value="PENTHOUSE">Penthouse</option>
                                    </select>
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700">Bedrooms</label>
                                    <input type="number" required value={formData.bedrooms} onChange={e => setFormData({ ...formData, bedrooms: e.target.value })} className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3" />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700">Area (sqft)</label>
                                    <input type="number" required value={formData.area} onChange={e => setFormData({ ...formData, area: e.target.value })} className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3" />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700">Status</label>
                                    <select value={formData.status} onChange={e => setFormData({ ...formData, status: e.target.value })} className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3">
                                        <option value="UNDER_CONSTRUCTION">Under Construction</option>
                                        <option value="READY">Ready</option>
                                        <option value="HANDOVER_COMPLETE">Handover Complete</option>
                                    </select>
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700">Completion %</label>
                                    <input type="number" required value={formData.completionPercentage} onChange={e => setFormData({ ...formData, completionPercentage: e.target.value })} className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3" />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700">Current Phase (Optional)</label>
                                    <input type="text" value={formData.currentPhase} onChange={e => setFormData({ ...formData, currentPhase: e.target.value })} className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3" />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700">Estimated Completion (Optional)</label>
                                    <input type="text" value={formData.estimatedCompletion} onChange={e => setFormData({ ...formData, estimatedCompletion: e.target.value })} className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3" placeholder="e.g. Q4 2024" />
                                </div>
                                <div className="col-span-1 md:col-span-2">
                                    <label className="block text-sm font-medium text-gray-700">Image URL (Optional)</label>
                                    <input type="text" value={formData.imageUrl} onChange={e => setFormData({ ...formData, imageUrl: e.target.value })} className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3" placeholder="https://example.com/image.jpg" />
                                </div>
                            </div>
                            <div className="flex justify-end pt-4">
                                <button type="submit" disabled={isLoading} className="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700">
                                    {isLoading ? 'Saving...' : isEditing ? 'Update Property' : 'Create Property'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

                {/* List Section */}
                <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
                    <div className="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
                        <h2 className="text-lg font-medium text-gray-900">Manage Properties</h2>
                    </div>
                    <div className="overflow-x-auto">
                        <table className="min-w-full divide-y divide-gray-200">
                            <thead className="bg-gray-50">
                                <tr>
                                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Unit / Name</th>
                                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Location</th>
                                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
                                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Image</th>
                                    <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="bg-white divide-y divide-gray-200">
                                {properties.map((prop) => (
                                    <tr key={prop.id}>
                                        <td className="px-6 py-4 whitespace-nowrap">
                                            <div className="text-sm font-medium text-gray-900">{prop.unitCode}</div>
                                            <div className="text-sm text-gray-500">{prop.name}</div>
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{prop.location}</td>
                                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{prop.propertyType}</td>
                                        <td className="px-6 py-4 whitespace-nowrap">
                                            <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${prop.status === 'READY' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'}`}>
                                                {prop.status}
                                            </span>
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                            {prop.imageUrl ? <a href={prop.imageUrl} target="_blank" rel="noreferrer" className="text-blue-600 hover:text-blue-800">View</a> : 'None'}
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                            <button onClick={() => handleEdit(prop)} className="text-indigo-600 hover:text-indigo-900 mr-4">
                                                <Edit2 className="w-4 h-4" />
                                            </button>
                                            <button onClick={() => handleDelete(prop.id)} className="text-red-600 hover:text-red-900">
                                                <Trash2 className="w-4 h-4" />
                                            </button>
                                        </td>
                                    </tr>
                                ))}
                                {properties.length === 0 && (
                                    <tr>
                                        <td colSpan="6" className="px-6 py-8 text-center text-gray-500">
                                            No properties found
                                        </td>
                                    </tr>
                                )}
                            </tbody>
                        </table>
                    </div>
                </div>
            </main>
        </div>
    );
}
