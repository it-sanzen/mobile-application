import { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import api from '../api';
import { Newspaper, LogOut, Plus, Trash2, CheckCircle2 } from 'lucide-react';

export default function CompanyNewsManager() {
    const [news, setNews] = useState([]);
    const [formData, setFormData] = useState({
        title: '',
        description: '',
        time: '',
        category: 'ANNOUNCEMENT',
        isPublished: true,
        isFeatured: false
    });
    const [status, setStatus] = useState({ type: '', message: '' });
    const [isLoading, setIsLoading] = useState(false);
    const navigate = useNavigate();

    const user = JSON.parse(localStorage.getItem('admin_user') || '{}');

    useEffect(() => {
        fetchNews();
    }, []);

    const fetchNews = async () => {
        try {
            const response = await api.get('/company-news');
            setNews(response.data);
        } catch (error) {
            console.error('Failed to fetch news:', error);
        }
    };

    const handleLogout = () => {
        localStorage.removeItem('admin_token');
        localStorage.removeItem('admin_user');
        navigate('/login');
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setIsLoading(true);
        setStatus({ type: '', message: '' });

        try {
            await api.post('/company-news', formData);
            setStatus({ type: 'success', message: 'News article published successfully!' });
            setFormData({ title: '', description: '', time: '', category: 'ANNOUNCEMENT', isPublished: true, isFeatured: false });
            fetchNews();
        } catch (err) {
            setStatus({ type: 'error', message: err.response?.data?.message || 'Failed to create news' });
        } finally {
            setIsLoading(false);
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm('Are you sure you want to delete this news article?')) return;
        try {
            await api.delete(`/company-news/${id}`);
            fetchNews();
        } catch (error) {
            alert('Failed to delete news article');
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
                                <Link to="/company-news" className="text-blue-600 border-b-2 border-blue-600 px-3 py-2 text-sm font-medium">Company News</Link>
                                <Link to="/unit-updates" className="text-gray-500 hover:text-gray-700 px-3 py-2 text-sm font-medium">Unit Updates</Link>
                                <Link to="/timeline" className="text-gray-500 hover:text-gray-700 px-3 py-2 text-sm font-medium">Timelines</Link>
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
                <div className="md:grid md:grid-cols-3 md:gap-8">
                    <div className="md:col-span-1">
                        <div className="px-4 sm:px-0">
                            <h3 className="text-lg font-medium leading-6 text-gray-900">Post Company News</h3>
                            <p className="mt-1 text-sm text-gray-600">
                                Create an announcement or news article that will be instantly visible on the home screen of all mobile apps.
                            </p>
                        </div>

                        {status.message && (
                            <div className={`mt-4 p-4 rounded-md flex ${status.type === 'success' ? 'bg-green-50' : 'bg-red-50'}`}>
                                {status.type === 'success' && <CheckCircle2 className="h-5 w-5 text-green-400 mr-2" />}
                                <span className={`text-sm font-medium ${status.type === 'success' ? 'text-green-800' : 'text-red-800'}`}>
                                    {status.message}
                                </span>
                            </div>
                        )}

                        <form onSubmit={handleSubmit} className="mt-5 space-y-4 bg-white p-6 shadow sm:rounded-md">
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Headline Title</label>
                                <input type="text" required value={formData.title} onChange={(e) => setFormData({ ...formData, title: e.target.value })} className="mt-1 block w-full border border-gray-300 rounded-md py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm" />
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-gray-700">Reading Time (e.g. "3 min read")</label>
                                <input type="text" required value={formData.time} onChange={(e) => setFormData({ ...formData, time: e.target.value })} className="mt-1 block w-full border border-gray-300 rounded-md py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm" />
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-gray-700">Category</label>
                                <select value={formData.category} onChange={(e) => setFormData({ ...formData, category: e.target.value })} className="mt-1 block w-full border border-gray-300 rounded-md py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                                    <option value="ANNOUNCEMENT">Announcement</option>
                                    <option value="AWARD">Award</option>
                                    <option value="EVENT">Event</option>
                                    <option value="SUSTAINABILITY">Sustainability</option>
                                    <option value="COMMUNITY">Community</option>
                                </select>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-gray-700">Message Content</label>
                                <textarea required rows={4} value={formData.description} onChange={(e) => setFormData({ ...formData, description: e.target.value })} className="mt-1 block w-full border border-gray-300 rounded-md py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm" />
                            </div>

                            <div className="flex items-center">
                                <input type="checkbox" checked={formData.isFeatured} onChange={(e) => setFormData({ ...formData, isFeatured: e.target.checked })} className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded" />
                                <label className="ml-2 block text-sm text-gray-900">Feature on top of feed?</label>
                            </div>

                            <button type="submit" disabled={isLoading} className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50">
                                {isLoading ? 'Publishing...' : 'Publish Article'}
                            </button>
                        </form>
                    </div>

                    <div className="md:col-span-2 mt-8 md:mt-0">
                        <div className="bg-white shadow overflow-hidden sm:rounded-md">
                            <ul className="divide-y divide-gray-200">
                                {news.length === 0 ? (
                                    <li className="px-6 py-12 text-center text-gray-500">No news articles published yet.</li>
                                ) : (
                                    news.map((n) => (
                                        <li key={n.id} className="px-4 py-4 sm:px-6 flex justify-between items-center hover:bg-gray-50">
                                            <div className="flex items-center">
                                                <div className="flex-shrink-0">
                                                    <Newspaper className="h-6 w-6 text-gray-400" />
                                                </div>
                                                <div className="ml-4">
                                                    <div className="text-sm font-medium text-blue-600">{n.title}</div>
                                                    <div className="text-sm text-gray-500">
                                                        {n.category} • {new Date(n.publishedAt).toLocaleDateString()}
                                                    </div>
                                                </div>
                                            </div>
                                            <button onClick={() => handleDelete(n.id)} className="text-red-600 hover:text-red-900">
                                                <Trash2 className="h-5 w-5" />
                                            </button>
                                        </li>
                                    ))
                                )}
                            </ul>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    );
}
