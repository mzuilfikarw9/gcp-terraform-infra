// import { useState } from 'react'
// import axios from 'axios'

// function App() {
//   const [status, setStatus] = useState("Idle")
//   const [orderId, setOrderId] = useState(null)
//   const [loading, setLoading] = useState(false)

//   const buyTicket = async () => {
//     setLoading(true)
//     setStatus("Sending Order...")
//     try {
//       const res = await axios.post("/api/buy", { 
//         ticket_count: 1 
//       })
//       setOrderId(res.data.order_id)
//       setStatus("✅ Order Queued! (Processed by Kafka)")
//     } catch (e) {
//       console.error(e)
//       setStatus("❌ Error: " + (e.response?.data?.error || e.message))
//     }
//     setLoading(false)
//   }

//   return (
//     <div style={{ padding: "50px", fontFamily: "Arial", textAlign: "center" }}>
//       <h1>🎟️ High-Load Ticket System</h1>
//       <div style={{ border: "1px solid #ccc", padding: "20px", borderRadius: "10px", maxWidth: "400px", margin: "0 auto" }}>
//         <h3>Concerto Coldplay Jakarta</h3>
//         <p>Price: $150</p>
        
//         <button 
//           onClick={buyTicket} 
//           disabled={loading}
//           style={{ 
//             padding: "15px 30px", fontSize: "18px", 
//             backgroundColor: loading ? "#ccc" : "#007bff", color: "white", 
//             border: "none", borderRadius: "5px", cursor: "pointer"
//           }}
//         >
//           {loading ? "Processing..." : "BUY TICKET NOW"}
//         </button>

//         <div style={{ marginTop: "20px", fontWeight: "bold" }}>
//           Status: {status}
//         </div>
        
//         {orderId && (
//           <div style={{ marginTop: "10px", color: "green" }}>
//             Order ID: {orderId}
//           </div>
//         )}
//       </div>
//     </div>
//   )
// }

// export default App

import { useState } from 'react'
import axios from 'axios'

function App() {
  const [status, setStatus] = useState("Idle")
  const [orderId, setOrderId] = useState(null)
  const [loading, setLoading] = useState(false)

  const buyTicket = async () => {
    setLoading(true)
    setStatus("Sending Order...")
    try {
      const res = await axios.post("/api/buy", { 
        ticket_count: 1 
      })
      setOrderId(res.data.order_id)
      setStatus("✅ Order Queued! (Processed by Kafka)")
    } catch (e) {
      console.error(e)
      setStatus("❌ Error: " + (e.response?.data?.error || e.message))
    }
    setLoading(false)
  }

  return (
    <div style={{ padding: "50px", fontFamily: "Arial", textAlign: "center" }}>
      <h1>🎟️ High-Load Ticket System</h1>
      <div style={{ border: "1px solid #ccc", padding: "20px", borderRadius: "10px", maxWidth: "400px", margin: "0 auto" }}>
        <h3>Concerto Coldplay Jakarta</h3>
        <p style={{ color: "red", fontWeight: "bold" }}>🔥 SELLING FAST! 🔥</p>
        <p>Price: $150</p>
        
        <button 
          onClick={buyTicket} 
          disabled={loading}
          style={{ 
            padding: "15px 30px", fontSize: "18px", 
            backgroundColor: loading ? "#ccc" : "#dc3545", // <--- CHANGED TO RED
            color: "white", 
            border: "none", borderRadius: "5px", cursor: "pointer"
          }}
        >
          {loading ? "Processing..." : "BUY TICKET (LAST CHANCE)"}
        </button>

        <div style={{ marginTop: "20px", fontWeight: "bold" }}>
          Status: {status}
        </div>
        
        {orderId && (
          <div style={{ marginTop: "10px", color: "green" }}>
            Order ID: {orderId}
          </div>
        )}
      </div>
    </div>
  )
}

export default App