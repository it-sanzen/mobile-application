import { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import api from '../api';
import { Users, LogOut, CheckCircle2, FileText, Upload, Trash2, ArrowLeft } from 'lucide-react';

export default function Documents() {
    const [users, setUsers] = useState([]);
    const [documents, setDocuments] = useState([]);
    const [uploadData, setUploadData] = useState({
        title: '',
        type: 'Contract',
        userId: '',
        file: null
    });
    const [status, setStatus] = useState({ type: '', message: '' });
    const [error, setError] = useState('');
    const [isLoading, setIsLoading] = useState(false);
    const [isDeleting, setIsDeleting] = useState(false);
    const [isFetching, setIsFetching] = useState(true);
    const [isCustomType, setIsCustomType] = useState(false);
    const [customType, setCustomType] = useState('');
    const navigate = useNavigate();

    const documentTypes = ['Contract', 'Receipt', 'NOC', 'Title Deed', 'Identification', 'Other'];

    const currentUser = JSON.parse(localStorage.getItem('admin_user') || '{}');

    useEffect(() => {
        fetchInitialData();
    }, []);

    const fetchInitialData = async () => {
        setIsFetching(true);
        try {
            const [usersRes, docsRes] = await Promise.all([
                api.get('/admin/users'),
                api.get('/documents')
            ]);
            setUsers(usersRes.data);
            setDocuments(docsRes.data);
        } catch (err) {
            console.error('Failed to fetch data', err);
            setStatus({ type: 'error', message: 'Failed to load initial data' });
        } finally {
            setIsFetching(false);
        }
    };

    const handleLogout = () => {
        localStorage.removeItem('admin_token');
        localStorage.removeItem('admin_user');
        navigate('/login');
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (!uploadData.file || !uploadData.userId) {
            setStatus({ type: 'error', message: 'Please select a user and a file' });
            return;
        }
        if (isCustomType && !customType.trim()) {
            setStatus({ type: 'error', message: 'Please enter a name for the custom type' });
            return;
        }

        setIsLoading(true);
        setStatus({ type: '', message: '' });

        const data = new FormData();
        data.append('title', uploadData.title);
        data.append('type', isCustomType ? customType : uploadData.type);
        data.append('userId', uploadData.userId);
        data.append('file', uploadData.file);

        try {
            await api.post('/documents/upload', data, {
                headers: {
                    'Content-Type': 'multipart/form-data'
                }
            });

            setStatus({
                type: 'success',
                message: 'Document uploaded successfully!'
            });
            setUploadData({ title: '', type: 'Contract', userId: '', file: null });
            setIsCustomType(false);
            setCustomType('');
            // Reset file input manually
            e.target.reset();
            fetchInitialData();
        } catch (err) {
            setStatus({
                type: 'error',
                message: err.response?.data?.message || 'Failed to upload document'
            });
        } finally {
            setIsLoading(false);
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm('Are you sure you want to delete this document?')) return;

        try {
            await api.delete(`/documents/${id}`);
            setDocuments(documents.filter(doc => doc.id !== id));
            setStatus({ type: 'success', message: 'Document deleted' });
        } catch (err) {
            setStatus({ type: 'error', message: 'Failed to delete document' });
        }
    };

    return (
        <div className="min-h-screen bg-gray-50 flex flex-col">
            <nav className="bg-white border-b border-gray-200">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="flex justify-between h-16">
                        <div className="flex items-center space-x-8">
                            <div className="flex items-center">
                                <Users className="w-8 h-8 text-blue-600 mr-3" />
                                <span className="text-xl font-bold text-gray-900">Admin Portal</span>
                            </div>
                            <div className="hidden sm:flex sm:space-x-4">
                                <Link to="/dashboard" className="text-gray-500 hover:text-gray-700 px-3 py-2 text-sm font-medium">Users</Link>
                                <Link to="/documents" className="text-blue-600 border-b-2 border-blue-600 px-3 py-2 text-sm font-medium">Documents</Link>
                                <Link to="/company-news" className="text-gray-500 hover:text-gray-700 px-3 py-2 text-sm font-medium">Company News</Link>
                                <Link to="/unit-updates" className="text-gray-500 hover:text-gray-700 px-3 py-2 text-sm font-medium">Unit Updates</Link>
                                <Link to="/timeline" className="text-gray-500 hover:text-gray-700 px-3 py-2 text-sm font-medium">Timelines</Link>
                                <Link to="/properties" className="text-gray-500 hover:text-gray-700 px-3 py-2 text-sm font-medium">Properties</Link>
                            </div>
                        </div>
                        <div className="flex items-center space-x-4">
                            <span className="text-sm text-gray-600">
                                Welcome, {currentUser.name}
                            </span>
                            <button
                                onClick={handleLogout}
                                className="flex items-center text-sm font-medium text-gray-500 hover:text-gray-900"
                            >
                                <LogOut className="w-4 h-4 mr-1" />
                                Logout
                            </button>
                        </div>
                    </div>
                </div>
            </nav>

            <main className="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-10">
                <div className="space-y-10">
                    {/* Upload Section */}
                    <div className="md:grid md:grid-cols-3 md:gap-8">
                        <div className="md:col-span-1">
                            <div className="px-4 sm:px-0">
                                <h3 className="text-lg font-medium leading-6 text-gray-900">
                                    Upload Document
                                </h3>
                                <p className="mt-1 text-sm text-gray-600">
                                    Upload a new document for a user. Supports PDF, Images, etc.
                                </p>
                            </div>
                        </div>

                        <div className="mt-5 md:mt-0 md:col-span-2">
                            <div className="shadow sm:rounded-md sm:overflow-hidden">
                                <div className="bg-white py-6 px-4 space-y-6 sm:p-6">
                                    {status.message && (
                                        <div className={`p-4 rounded-md flex ${status.type === 'success' ? 'bg-green-50' : 'bg-red-50'}`}>
                                            {status.type === 'success' && <CheckCircle2 className="h-5 w-5 text-green-400 mr-2" />}
                                            <span className={`text-sm font-medium ${status.type === 'success' ? 'text-green-800' : 'text-red-800'}`}>
                                                {status.message}
                                            </span>
                                        </div>
                                    )}

                                    <form onSubmit={handleSubmit} className="space-y-6">
                                        <div className="grid grid-cols-6 gap-6">
                                            <div className="col-span-6 sm:col-span-3">
                                                <label className="block text-sm font-medium text-gray-700">Select User</label>
                                                <select
                                                    required
                                                    value={uploadData.userId}
                                                    onChange={(e) => setUploadData({ ...uploadData, userId: e.target.value })}
                                                    className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                                                >
                                                    <option value="">Select a user...</option>
                                                    {users.map(u => (
                                                        <option key={u.id} value={u.id}>{u.name} ({u.unit || 'No Unit'})</option>
                                                    ))}
                                                </select>
                                            </div>

                                            <div className="col-span-6 sm:col-span-3">
                                                <label className="block text-sm font-medium text-gray-700">Document Type</label>
                                                <select
                                                    value={isCustomType ? 'Custom' : uploadData.type}
                                                    onChange={(e) => {
                                                        if (e.target.value === 'Custom') {
                                                            setIsCustomType(true);
                                                            setUploadData({ ...uploadData, type: '' }); // Clear type when switching to custom
                                                        } else {
                                                            setIsCustomType(false);
                                                            setCustomType(''); // Clear custom type when switching back
                                                            setUploadData({ ...uploadData, type: e.target.value });
                                                        }
                                                    }}
                                                    className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                                                >
                                                    {documentTypes.map(type => (
                                                        <option key={type} value={type}>{type}</option>
                                                    ))}
                                                    <option value="Custom">+ Add Custom Type</option>
                                                </select>
                                            </div>

                                            {isCustomType && (
                                                <div className="col-span-6 sm:col-span-3">
                                                    <label className="block text-sm font-medium text-gray-700">Custom Type Name</label>
                                                    <input
                                                        type="text"
                                                        required
                                                        className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                                                        placeholder="Enter type name..."
                                                        value={customType}
                                                        onChange={(e) => setCustomType(e.target.value)}
                                                    />
                                                </div>
                                            )}

                                            <div className="col-span-6">
                                                <label className="block text-sm font-medium text-gray-700">Document Title</label>
                                                <input
                                                    type="text"
                                                    required
                                                    value={uploadData.title}
                                                    placeholder="e.g. Sales Purchase Agreement"
                                                    onChange={(e) => setUploadData({ ...uploadData, title: e.target.value })}
                                                    className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                                                />
                                            </div>

                                            <div className="col-span-6">
                                                <label className="block text-sm font-medium text-gray-700">File</label>
                                                <div className="mt-1 flex justify-center px-6 pt-5 pb-6 border-2 border-gray-300 border-dashed rounded-md">
                                                    <div className="space-y-1 text-center">
                                                        <Upload className="mx-auto h-12 w-12 text-gray-400" />
                                                        <div className="flex text-sm text-gray-600">
                                                            <label className="relative cursor-pointer bg-white rounded-md font-medium text-blue-600 hover:text-blue-500 focus-within:outline-none">
                                                                <span>Upload a file</span>
                                                                <input
                                                                    type="file"
                                                                    className="sr-only"
                                                                    onChange={(e) => setUploadData({ ...uploadData, file: e.target.files[0] })}
                                                                />
                                                            </label>
                                                        </div>
                                                        <p className="text-xs text-gray-500">
                                                            {uploadData.file ? uploadData.file.name : 'PDF, PNG, JPG up to 10MB'}
                                                        </p>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <div className="flex justify-end">
                                            <button
                                                type="submit"
                                                disabled={isLoading}
                                                className="ml-3 inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50"
                                            >
                                                {isLoading ? 'Uploading...' : 'Upload Document'}
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* List Section */}
                    <div className="bg-white shadow sm:rounded-lg overflow-hidden">
                        <div className="px-4 py-5 sm:px-6 border-b border-gray-200">
                            <h3 className="text-lg leading-6 font-medium text-gray-900">
                                All Documents
                            </h3>
                        </div>
                        {isFetching ? (
                            <div className="p-8 text-center text-gray-500">Loading documents...</div>
                        ) : documents.length === 0 ? (
                            <div className="p-8 text-center text-gray-500">No documents found.</div>
                        ) : (
                            <div className="overflow-x-auto">
                                <table className="min-w-full divide-y divide-gray-200">
                                    <thead className="bg-gray-50">
                                        <tr>
                                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Title</th>
                                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
                                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">User</th>
                                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date</th>
                                            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody className="bg-white divide-y divide-gray-200">
                                        {documents.map((doc) => (
                                            <tr key={doc.id}>
                                                <td className="px-6 py-4 whitespace-nowrap">
                                                    <div className="flex items-center">
                                                        <FileText className="h-5 w-5 text-gray-400 mr-2" />
                                                        <span className="text-sm font-medium text-gray-900">{doc.title}</span>
                                                    </div>
                                                </td>
                                                <td className="px-6 py-4 whitespace-nowrap">
                                                    <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800">
                                                        {doc.type}
                                                    </span>
                                                </td>
                                                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                                    {doc.user?.name}
                                                </td>
                                                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                                    {new Date(doc.createdAt).toLocaleDateString()}
                                                </td>
                                                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                                    <button
                                                        onClick={() => handleDelete(doc.id)}
                                                        className="text-red-600 hover:text-red-900"
                                                    >
                                                        <Trash2 className="h-5 w-5" />
                                                    </button>
                                                </td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        )}
                    </div>
                </div>
            </main>
        </div>
    );
}
