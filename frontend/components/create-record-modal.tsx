type Props = {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
};

import { useState } from "react";
import { createRecord } from "../utils/api";

export default function CreateRecordModal({
  isOpen,
  onClose,
  onSuccess,
}: Props) {
  const [formData, setFormData] = useState({ name: "", email: "", role: "" });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await createRecord("users", formData);
      setFormData({ name: "", email: "", role: "" });
      onSuccess();
      onClose();
    } catch (err) {
      alert(`Failed to create record: ${err}`);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-40 flex justify-center items-center z-50">
      <div className="bg-white p-6 rounded shadow-md w-full max-w-md relative">
        <h3 className="text-lg font-bold mb-4">Add New User</h3>
        <form onSubmit={handleSubmit} className="space-y-3">
          {["name", "email", "role"].map((field) => (
            <input
              key={field}
              name={field}
              value={formData[field as keyof typeof formData]}
              onChange={(e) =>
                setFormData({ ...formData, [e.target.name]: e.target.value })
              }
              placeholder={field[0].toUpperCase() + field.slice(1)}
              className="w-full border rounded p-2"
              required
            />
          ))}
          <div className="flex justify-end gap-2 pt-2">
            <button
              type="button"
              onClick={onClose}
              className="border border-gray-300 text-gray-600 hover:bg-gray-100 px-4 py-2 rounded"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="border border-gray-800 text-gray-800 hover:bg-gray-100 px-4 py-2 rounded shadow-sm"
            >
              Save
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
