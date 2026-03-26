import { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import api from '../api';
import { LogOut, Package, CheckCircle2, XCircle, Clock, Eye } from 'lucide-react';

export default function AddonQuotesManager() {
    const [quotes, setQuotes] = useState([]);
    const [isLoading, setIsLoading] = useState(true);
    const [selectedQuote, setSelectedQuote] = useState(null);
    const [adminNotes, setAdminNotes] = useState('');
    const [statusFilter, setStatusFilter] = useState('ALL');
    const navigate = useNavigate();

    const user = JSON.parse(localStorage.getItem('admin_user') || '{}');

    const handleLogout = () => {
        localStorage.removeItem('admin_token');
        localStorage.removeItem('admin_user');
        navigate('/login');
    };

    const fetchQuotes = async () => {
        setIsLoading(true);
        try {
            const res = await api.get('/addon-quotes/admin/all');
            setQuotes(res.data);
        } catch (err) {
            console.error('Failed to fetch quotes:', err);
        }
        setIsLoading(false);
    };

    useEffect(() => { fetchQuotes(); }, []);

    const updateStatus = async (id, status) => {
        try {
            await api.patch(`/addon-quotes/${id}/status`, { status, adminNotes: adminNotes || undefined });
            setSelectedQuote(null);
            setAdminNotes('');
            fetchQuotes();
        } catch (err) {
            console.error('Failed to update status:', err);
        }
    };

    const filteredQuotes = statusFilter === 'ALL' ? quotes : quotes.filter(q => q.status === statusFilter);

    const statusColor = (status) => {
        switch (status) {
            case 'PENDING': return 'bg-yellow-100 text-yellow-800';
            case 'REVIEWED': return 'bg-blue-100 text-blue-800';
            case 'APPROVED': return 'bg-green-100 text-green-800';
            case 'REJECTED': return 'bg-red-100 text-red-800';
            default: return 'bg-gray-100 text-gray-800';
        }
    };

    const formatDate = (d) => new Date(d).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });

    return (
        <div className="min-h-screen bg-gray-50">
            <nav className="bg-white shadow-sm border-b">
                <div className="max-w-7xl mx-auto px-4">
                    <div className="flex justify-between h-14">
                        <div className="flex items-center space-x-1 overflow-x-auto">
                            <Link to="/dashboard" className="text-gray-500 hover:text-gray-700 px-3 py-2 text-sm font-medium">Users</Link>
                            <Link to="/documents" className="text-gray-500 hover:text-gray-700 px-3 py-2 text-sm font-medium">Documents</Link>
                            <Link to="/company-news" className="text-gray-500 hover:text-gray-700 px-3 py-2 text-sm font-medium">Company News</Link>
                            <Link to="/unit-updates" className="text-gray-500 hover:text-gray-700 px-3 py-2 text-sm font-medium">Unit Updates</Link>
                            <Link to="/timeline" className="text-gray-500 hover:text-gray-700 px-3 py-2 text-sm font-medium">Timelines</Link>
                            <Link to="/properties" className="text-gray-500 hover:text-gray-700 px-3 py-2 text-sm font-medium">Properties</Link>
                            <Link to="/addon-quotes" className="text-blue-600 border-b-2 border-blue-600 px-3 py-2 text-sm font-medium">Add-on Quotes</Link>
                        </div>
                        <div className="flex items-center gap-3">
                            <span className="text-sm text-gray-600">{user.name || 'Admin'}</span>
                            <button onClick={handleLogout} className="text-gray-400 hover:text-red-500"><LogOut size={18} /></button>
                        </div>
                    </div>
                </div>
            </nav>

            <div className="max-w-7xl mx-auto px-4 py-6">
                <div className="flex items-center justify-between mb-6">
                    <div>
                        <h1 className="text-2xl font-bold text-gray-900">Add-on Quotes</h1>
                        <p className="text-sm text-gray-500 mt-1">Manage customer add-on quote requests</p>
                    </div>
                    <div className="flex gap-2">
                        {['ALL', 'PENDING', 'REVIEWED', 'APPROVED', 'REJECTED'].map(s => (
                            <button key={s} onClick={() => setStatusFilter(s)}
                                className={`px-3 py-1.5 text-xs font-medium rounded-full ${statusFilter === s ? 'bg-blue-600 text-white' : 'bg-white text-gray-600 border'}`}>
                                {s === 'ALL' ? `All (${quotes.length})` : `${s.charAt(0) + s.slice(1).toLowerCase()} (${quotes.filter(q => q.status === s).length})`}
                            </button>
                        ))}
                    </div>
                </div>

                {isLoading ? (
                    <div className="text-center py-12 text-gray-500">Loading...</div>
                ) : filteredQuotes.length === 0 ? (
                    <div className="text-center py-12">
                        <Package className="mx-auto mb-3 text-gray-300" size={48} />
                        <p className="text-gray-500">No quotes found</p>
                    </div>
                ) : (
                    <div className="space-y-4">
                        {filteredQuotes.map(quote => (
                            <div key={quote.id} className="bg-white rounded-lg shadow-sm border p-5">
                                <div className="flex items-start justify-between">
                                    <div>
                                        <div className="flex items-center gap-3 mb-1">
                                            <h3 className="font-semibold text-gray-900">{quote.user?.name || 'User'}</h3>
                                            <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${statusColor(quote.status)}`}>{quote.status}</span>
                                        </div>
                                        <p className="text-sm text-gray-500">{quote.user?.email} | {quote.user?.phone}</p>
                                        <p className="text-sm text-gray-500 mt-1">Property: {quote.property?.name} - {quote.property?.location}</p>
                                        <p className="text-xs text-gray-400 mt-1">{formatDate(quote.createdAt)}</p>
                                    </div>
                                    <div className="text-right">
                                        <p className="text-lg font-bold text-green-700">AED {quote.totalPrice?.toLocaleString()}</p>
                                        <p className="text-xs text-gray-400">{quote.items?.length || 0} add-on(s)</p>
                                    </div>
                                </div>

                                {/* Items */}
                                <div className="mt-3 flex flex-wrap gap-2">
                                    {quote.items?.map(item => (
                                        <span key={item.id} className="bg-gray-100 px-3 py-1 rounded-full text-xs font-medium text-gray-700">
                                            {item.addonOffer?.title} — AED {item.price?.toLocaleString()}
                                        </span>
                                    ))}
                                </div>

                                {quote.adminNotes && (
                                    <div className="mt-3 bg-blue-50 border border-blue-100 rounded-lg p-3">
                                        <p className="text-sm text-blue-800"><strong>Admin Notes:</strong> {quote.adminNotes}</p>
                                    </div>
                                )}

                                {/* Actions */}
                                {selectedQuote === quote.id ? (
                                    <div className="mt-4 border-t pt-4">
                                        <textarea value={adminNotes} onChange={e => setAdminNotes(e.target.value)}
                                            placeholder="Add notes (optional)..."
                                            className="w-full border rounded-lg p-3 text-sm mb-3" rows={2} />
                                        <div className="flex gap-2">
                                            <button onClick={() => updateStatus(quote.id, 'REVIEWED')}
                                                className="flex items-center gap-1 px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700">
                                                <Eye size={14} /> Mark Reviewed
                                            </button>
                                            <button onClick={() => updateStatus(quote.id, 'APPROVED')}
                                                className="flex items-center gap-1 px-4 py-2 bg-green-600 text-white rounded-lg text-sm font-medium hover:bg-green-700">
                                                <CheckCircle2 size={14} /> Approve
                                            </button>
                                            <button onClick={() => updateStatus(quote.id, 'REJECTED')}
                                                className="flex items-center gap-1 px-4 py-2 bg-red-600 text-white rounded-lg text-sm font-medium hover:bg-red-700">
                                                <XCircle size={14} /> Reject
                                            </button>
                                            <button onClick={() => { setSelectedQuote(null); setAdminNotes(''); }}
                                                className="px-4 py-2 bg-gray-100 text-gray-600 rounded-lg text-sm font-medium hover:bg-gray-200">
                                                Cancel
                                            </button>
                                        </div>
                                    </div>
                                ) : (
                                    <div className="mt-3 flex justify-end">
                                        <button onClick={() => setSelectedQuote(quote.id)}
                                            className="text-sm text-blue-600 hover:text-blue-800 font-medium">
                                            Manage Quote →
                                        </button>
                                    </div>
                                )}
                            </div>
                        ))}
                    </div>
                )}
            </div>
        </div>
    );
}
